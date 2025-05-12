import Foundation
import Model

public protocol ProductListingViewModelProtocol2: ObservableObject {
    var state: PaginatedViewState2<ProductListingViewStateModel2, ProductListingViewErrorType2> { get }
    var products: [Product] { get }
    var wishlistContent: [SelectedProduct] { get }
    var style: ProductListingListStyle2 { get set }
    var showRefine: Bool { get set }
    var sortOption: String? { get set }
    var title: String { get }
    var totalNumberOfProducts: Int { get }
    var showSearchButton: Bool { get }

    func viewDidAppear()
    func didDisplay(_ product: Product)
    func didSelect(_ product: Product)
    func isFavoriteState(for product: Product) -> Bool
    func didTapSearch()
    func didTapAddToWishlist(for product: Product, isFavorite: Bool)
    func setListStyle(_ style: ProductListingListStyle2)
    func didApplyFilters()
}
