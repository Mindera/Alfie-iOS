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
            await load(.firstPage)
        }
        Task {
            await loadPriceBoundsIfNeeded()
        }
    }

    public func didDisplay(_ product: Product) {
        guard products.last?.id == product.id, !state.isLoadingNextPage else { return }

        Task {
            await load(.nextPage)
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
        publish(pager.state)

        Task {
            await load(.firstPage)
        }
    }

    @MainActor
    public func refresh() async {
        await load(.refresh)
    }

    public func didDismissTransientError() {
        transientError = nil
    }

    @MainActor
    public func retry() async {
        await load(.firstPage)
    }

    // MARK: - Private

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
    private func load(_ request: ProductListingPageRequest) async {
        guard let ticket = pager.begin(request) else { return }
        if request == .refresh {
            transientError = nil
        }
        publish(pager.state)

        let result: Result<ProductListing?, Error>
        do {
            result = .success(try await fetchPage(after: ticket.cursor))
        } catch {
            result = .failure(error)
        }

        guard let commit = pager.commit(result, for: ticket) else { return }
        if case .failure(let error) = result, !(error is CancellationError) {
            dependencies.log.error("Error fetching product listing (\(request)): \(error)")
        }
        publish(pager.state)
        if let error = commit.transientError {
            transientError = error
        }
    }

    private func publish(_ newState: ProductListingPager.State) {
        guard state != newState else { return }
        state = newState
    }

    /// Routes a page request to the right operation for the screen's mode: category
    /// browsing hits `productList`, search results hit `searchProducts`. Returns nil when
    /// the key required for the current mode is missing, which the pager commits as no results.
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
