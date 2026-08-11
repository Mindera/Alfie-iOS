import Foundation

public protocol ProductListingViewModelProtocol: ObservableObject {
    var state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType> { get }
    // Transient (non-destructive) failure from pull-to-refresh; the grid stays on screen and the
    // View surfaces this as a Snackbar. Distinct from `state.error`, which is the full error screen.
    var refreshError: ProductListingViewErrorType? { get }
    var products: [Product] { get }
    var wishlistContent: [SelectedProduct] { get }
    var style: ProductListingListStyle { get set }
    var showRefine: Bool { get set }
    var sortOption: String? { get set }
    var title: String { get }
    var totalNumberOfProducts: Int { get }
    var showSearchButton: Bool { get }
    var isWishlistEnabled: Bool { get }

    func viewDidAppear()
    func didDisplay(_ product: Product)
    func didSelect(_ product: Product)
    func isFavoriteState(for product: Product) -> Bool
    func didTapSearch()
    func didTapAddToWishlist(for product: Product, isFavorite: Bool)
    func setListStyle(_ style: ProductListingListStyle)
    func didApplyFilters()
    func refresh() async
    func didDismissRefreshError()
    func retry() async
}
