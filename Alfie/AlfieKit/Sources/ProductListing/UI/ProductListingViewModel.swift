import Combine
import Core
import Foundation
import Model
import SwiftUI

// MARK: - ProductListingViewModel

public final class ProductListingViewModel: ProductListingViewModelProtocol {
    private let dependencies: ProductListingDependencyContainer
    private let category: String?
    private let query: String?
    private let mode: ProductListingViewMode
    @Published public var style: ProductListingListStyle
    @Published public var showRefine = false
    @Published public var sortOption: String?
    // Populated by the Refine sheet. Price is the only dimension the sheet exposes today; the
    // rest of `ProductFilterInput` waits on a BFF facet API.
    @Published public internal(set) var filters: ProductFilterInput?
    // Whole-collection price bounds for the Refine sheet's Price row. A plain optional rather
    // than a `ViewState`: the design has no loading or error affordance for it, and an absent
    // range is a legitimate answer — both cases simply mean the Price row is not shown.
    @Published public internal(set) var priceBounds: PriceFilterBounds?
    @Published public private(set) var wishlistContent: [SelectedProduct]
    private let navigate: (ProductListingRoute) -> Void
    private let showSearch: () -> Void
    @Published public private(set) var state: PaginatedViewState<
        ProductListingViewStateModel, ProductListingViewErrorType
    >
    // Transient pull-to-refresh failure: the grid stays put and the View shows a Snackbar. Never a
    // full `.error` screen — a failed refresh must not discard the products already on screen.
    @Published public private(set) var refreshError: ProductListingViewErrorType?

    /// Cursor state for cursor-based pagination. Lives on the ViewModel (which is the
    /// only caller that needs to drive "load more" decisions); the service itself is
    /// stateless and just fetches the page identified by `after`.
    private var pagination: ProductListing.Pagination?

    // True while a load-more or a refresh is in flight, so the two can't race and overwrite each
    // other (last-writer-wins).
    private var isFetching = false

    // The bounds query is fired at most once per screen, whatever it returns.
    private var didRequestPriceBounds = false

    // Bumped whenever the result set is redefined (a filter or sort change). A page fetch captures
    // the value at entry and refuses to commit if it no longer matches — otherwise a load-more or
    // refresh already in flight can land afterwards and restore the pre-filter products and cursor.
    private var resultSetGeneration = 0

    public enum Constants {
        public static let defaultSkeletonItemsSize = 12
    }

    public var products: [Product] {
        state.value?.products ?? []
    }

    public var title: String {
        state.value?.title ?? ""
    }

    public var totalNumberOfProducts: Int {
        pagination?.totalCount ?? 0
    }

    public var showSearchButton: Bool {
        !(state.isLoadingFirstPage || mode == .searchResults)
    }

    public var isWishlistEnabled: Bool {
        dependencies.configurationService.isFeatureEnabled(.wishlist)
    }

    public init(
        dependencies: ProductListingDependencyContainer,
        category: String? = nil,
        searchText: String? = nil,
        sort: String? = nil,
        urlQueryParameters: [String: String]? = nil,
        mode: ProductListingViewMode = .listing,
        skeletonItemsSize: Int = Constants.defaultSkeletonItemsSize,
        navigate: @escaping (ProductListingRoute) -> Void,
        showSearch: @escaping () -> Void
    ) {
        self.dependencies = dependencies
        style = dependencies.plpStyleListProvider.style
        self.category = category
        self.mode = mode
        sortOption = sort
        query = searchText ?? urlQueryParameters.map(\.values)?.joined(separator: ",")
        state = .loadingFirstPage(.init(title: "", products: .skeleton(itemsSize: skeletonItemsSize)))
        wishlistContent = []
        self.navigate = navigate
        self.showSearch = showSearch
    }

    public func viewDidAppear() {
        Task { @MainActor in
            wishlistContent = await dependencies.wishlistService.getWishlistContent()
        }
        Task {
            await loadProductsIfNeeded()
        }
        Task {
            await loadPriceBoundsIfNeeded()
        }
    }

    public func didDisplay(_ product: Product) {
        guard products.last?.id == product.id, !state.isLoadingNextPage else { return }

        Task {
            await loadMoreProducts()
        }
    }

    public func setListStyle(_ style: ProductListingListStyle) {
        dependencies.plpStyleListProvider.set(style)
    }

    public func didSelect(_ product: Product) {
        navigate(.productDetails(.productDetails(.product(product))))
    }

    public func isFavoriteState(for product: Product) -> Bool {
        wishlistContent.contains { $0.product.id == product.id }
    }

    public func didTapSearch() {
        showSearch()
    }

    public func didTapAddToWishlist(for product: Product, isFavorite: Bool) {
        Task { @MainActor in
            if !isFavorite {
                await dependencies.wishlistService.addProduct(SelectedProduct(product: product))
                dependencies.analytics.trackAddToWishlist(productID: product.id)
            } else {
                await dependencies.wishlistService.removeProduct(withId: product.id)
                dependencies.analytics.trackRemoveFromWishlist(productID: product.id)
            }
            wishlistContent = await dependencies.wishlistService.getWishlistContent()
        }
    }

    public func didApplyFilters(_ filters: ProductFilterInput?, sort: String?) {
        self.filters = filters
        sortOption = sort
        showRefine = false
        // Discard the cursor: an `after` from the previous query addresses a result set that no
        // longer exists, and would silently paginate into the old one (ALFMOB-487).
        pagination = nil
        // A failed pull-to-refresh describes the previous result set; leaving its Snackbar up over
        // a freshly filtered listing reads as the filter having failed.
        refreshError = nil
        // Invalidate anything already in flight. The filter bar stays tappable during a load-more
        // or refresh, so without this their responses can land after the reset and put the
        // pre-filter products (and cursor) back.
        resultSetGeneration += 1
        state = .loadingFirstPage(.init(title: "", products: []))

        Task {
            await loadProductsIfNeeded()
        }
    }

    @MainActor
    public func refresh() async {
        // Pull-to-refresh keeps the current grid on screen (no `.loadingFirstPage` skeleton flip) and
        // re-fetches page 1, preserving the active sort + filters. If a load-more or another refresh is
        // already running, bail — the in-flight fetch wins. The cursor is only reset (to the new page-1
        // pagination) on success, so a failed refresh leaves paging intact over the preserved grid.
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }
        refreshError = nil
        let generation = resultSetGeneration

        let productListing: ProductListing?

        do {
            productListing = try await fetchPage(after: nil)
        } catch is CancellationError {
            return
        } catch {
            guard generation == resultSetGeneration else { return }
            dependencies.log.error("Error refreshing product listing: \(error)")
            refreshError = ProductListingViewErrorType.from(error: error)
            return
        }

        // A filter or sort change during the fetch redefined the result set; this response
        // describes the old one.
        guard generation == resultSetGeneration else { return }

        guard let productListing else {
            refreshError = .noResults
            return
        }

        pagination = productListing.pagination
        state = .success(.init(title: productListing.title, products: productListing.products))
    }

    public func didDismissRefreshError() {
        // Clear the transient error once its Snackbar is dismissed, so it never lingers as stale state
        // and a later identical failure re-presents cleanly.
        refreshError = nil
    }

    @MainActor
    public func retry() async {
        // Recovery from the full error screen. Show the loading state for feedback, then re-fetch
        // page 1. Holds `isFetching` for the whole fetch so a concurrent pull-to-refresh (now
        // reachable over the error overlay) or a double-tap can't start a second racing page-1 fetch.
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }
        state = .loadingFirstPage(.init(title: "", products: []))
        await loadProductsIfNeeded()
    }

    // MARK: - Private

    @MainActor
    private func loadProductsIfNeeded() async {
        // Not gated on `isFetching`: this is the first-page / filter-apply load, and `didApplyFilters`
        // has already blanked the grid before calling it — dropping it here would strand an empty
        // screen. The `isFetching` guard is only for refresh-vs-load-more (which the ticket scoped).
        guard !state.isSuccess else {
            return
        }
        let generation = resultSetGeneration

        let productListing: ProductListing?

        do {
            productListing = try await fetchPage(after: nil)
        } catch {
            guard generation == resultSetGeneration else { return }
            dependencies.log.error("Error fetching product listing (first page): \(error)")
            state = .error(ProductListingViewErrorType.from(error: error))
            return
        }

        guard generation == resultSetGeneration else { return }

        guard let productListing else {
            state = .error(.noResults)
            return
        }

        pagination = productListing.pagination
        state = .success(.init(title: productListing.title, products: productListing.products))
    }

    /// Fetched once per screen. The bounds describe the whole collection: constant across
    /// pagination and unaffected by the active filters, mirroring web (ALFMOB-472). A failure
    /// is not surfaced — the Price row simply doesn't appear until the next `viewDidAppear`
    /// re-fetches it.
    @MainActor
    private func loadPriceBoundsIfNeeded() async {
        // Gated on "asked", not on "got a result": `viewDidAppear` fires again on every return
        // from a PDP, and a category with no filterable range legitimately yields nil — keying
        // off `priceBounds` would re-query it every time.
        guard !didRequestPriceBounds, mode == .listing, let collectionHandle = category else { return }
        didRequestPriceBounds = true

        do {
            let range = try await dependencies.productListingService.categoryPriceRange(
                collectionHandle: collectionHandle
            )
            priceBounds = range.flatMap(PriceFilterBounds.init(priceRange:))
        } catch {
            // Only the nil result must not be re-queried — it is a legitimate answer. A throw is
            // not, so release the latch: otherwise one transient failure hides the Price row for
            // the life of the screen, with no path back to it.
            didRequestPriceBounds = false
            dependencies.log.error("Error fetching category price range: \(error)")
        }
    }

    @MainActor
    private func loadMoreProducts() async {
        guard
            !isFetching,
            pagination?.hasNextPage == true,
            case .success(let model) = state
        else {
            return
        }
        isFetching = true
        defer { isFetching = false }
        let generation = resultSetGeneration

        state = .loadingNextPage(.init(title: title, products: products))
        let productListing: ProductListing?

        do {
            productListing = try await fetchPage(after: pagination?.endCursor)
        } catch {
            guard generation == resultSetGeneration else { return }
            dependencies.log.error("Error fetching product listing (following page): \(error)")
            state = .error(ProductListingViewErrorType.from(error: error))
            return
        }

        // The filter changed while this page was in flight — appending it would splice products
        // from the old result set onto the new one.
        guard generation == resultSetGeneration else { return }

        guard let productListing else {
            state = .error(.noResults)
            return
        }

        pagination = productListing.pagination
        state = .success(.init(title: title, products: model.products + productListing.products))
    }

    /// Routes a page request to the right operation for the screen's mode: category
    /// browsing hits `productList`, search results hit `searchProducts`. Returns nil when
    /// the key required for the current mode is missing, which callers surface as no-results.
    private func fetchPage(after: String?) async throws -> ProductListing? {
        switch mode {
        case .listing:
            guard let collectionHandle = category else { return nil }
            return try await dependencies.productListingService.productListPage(
                collectionHandle: collectionHandle,
                after: after,
                sort: sortOption,
                filters: filters
            )
        case .searchResults:
            guard let searchTerm = query else { return nil }
            return try await dependencies.productListingService.searchPage(
                searchTerm: searchTerm,
                after: after,
                sort: sortOption,
                filters: filters
            )
        }
    }
}

// MARK: - Skeleton

extension Collection where Element == Product {
    // swiftlint:disable:next strict_fileprivate
    fileprivate static func skeleton(itemsSize: Int) -> [Element] {
        Array(repeating: (), count: itemsSize).map { Element.empty }
    }
}

extension Product {
    // swiftlint:disable:next strict_fileprivate
    fileprivate static var empty: Product {
        let variant = Product.Variant(
            sku: "",
            size: nil,
            colour: nil,
            attributes: nil,
            stock: 0,
            price: .init(amount: .init(currencyCode: "AUD", amount: 0, amountFormatted: "$000,00"), was: nil)
        )
        return Product(
            id: UUID().uuidString,
            styleNumber: "",
            name: "",
            brand: Brand(id: "", name: "", slug: ""),
            shortDescription: "",
            slug: "",
            defaultVariant: variant,
            variants: [variant],
            colours: nil
        )
    }
}
