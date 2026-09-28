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
    @Published public private(set) var transientError: ProductListingTransientError?

    private var pager: ProductListingPager

    // The bounds query is fired at most once per screen, whatever it returns.
    private var didRequestPriceBounds = false

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
        pager.pagination?.totalCount ?? 0
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
        let initialState: ProductListingPager.State = .loadingFirstPage(
            .init(title: "", products: Product.skeletons(count: skeletonItemsSize))
        )
        state = initialState
        pager = .init(state: initialState)
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
        // A transient error describes the previous result set; leaving its Snackbar up over a
        // freshly filtered listing reads as the filter having failed.
        transientError = nil
        // Discards the cursor (ALFMOB-487) and invalidates any page request in flight, so it
        // cannot land afterwards and put the pre-filter products back.
        pager.resetResultSet()
        state = pager.state

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
        guard !pager.isFetching else { return }
        pager.isFetching = true
        defer { pager.isFetching = false }
        transientError = nil
        let generation = pager.generation

        let productListing: ProductListing?

        do {
            productListing = try await fetchPage(after: nil)
        } catch is CancellationError {
            return
        } catch {
            guard generation == pager.generation else { return }
            dependencies.log.error("Error refreshing product listing: \(error)")
            transientError = .init(request: .refresh, error: .from(error: error))
            return
        }

        // A filter or sort change during the fetch redefined the result set; this response
        // describes the old one.
        guard generation == pager.generation else { return }

        guard let productListing else {
            transientError = .init(request: .refresh, error: .noResults)
            return
        }

        pager.pagination = productListing.pagination
        pager.state = .success(.init(title: productListing.title, products: productListing.products))
        state = pager.state
    }

    public func didDismissTransientError() {
        // Clear the transient error once its Snackbar is dismissed, so it never lingers as stale state
        // and a later identical failure re-presents cleanly.
        transientError = nil
    }

    @MainActor
    public func retry() async {
        // Recovery from the full error screen. Show the loading state for feedback, then re-fetch
        // page 1. Holds `isFetching` for the whole fetch so a concurrent pull-to-refresh (now
        // reachable over the error overlay) or a double-tap can't start a second racing page-1 fetch.
        guard !pager.isFetching else { return }
        pager.isFetching = true
        defer { pager.isFetching = false }
        pager.state = .loadingFirstPage(.init(title: "", products: []))
        state = pager.state
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
        let generation = pager.generation

        let productListing: ProductListing?

        do {
            productListing = try await fetchPage(after: nil)
        } catch {
            guard generation == pager.generation else { return }
            dependencies.log.error("Error fetching product listing (first page): \(error)")
            pager.state = .error(ProductListingViewErrorType.from(error: error))
            state = pager.state
            return
        }

        guard generation == pager.generation else { return }

        guard let productListing else {
            pager.state = .error(.noResults)
            state = pager.state
            return
        }

        pager.pagination = productListing.pagination
        pager.state = .success(.init(title: productListing.title, products: productListing.products))
        state = pager.state
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
        guard let ticket = pager.beginNextPage() else { return }
        state = pager.state

        let result: Result<ProductListing?, Error>
        do {
            result = .success(try await fetchPage(after: ticket.cursor))
        } catch {
            dependencies.log.error("Error fetching product listing (next page): \(error)")
            result = .failure(error)
        }

        guard let commit = pager.commit(result, for: ticket) else { return }
        state = commit.state
        if let error = commit.transientError {
            transientError = error
        }
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
