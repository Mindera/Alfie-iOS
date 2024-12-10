import Combine
import Foundation

public struct ProductListingViewStateModel {
    public let title: String
    public let products: [Product]

    public init(title: String, products: [Product]) {
        self.title = title
        self.products = products
    }
}

public enum ProductListingViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case noResults
}

public enum ProductListingViewMode {
    case listing
    case searchResults
}

public protocol ProductListingViewModelProtocol: ObservableObject {
    var state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType> { get }
    var products: [Product] { get }
    var wishListContent: [Product] { get }
    var style: ProductListingListStyle { get set }
    var title: String { get }
    var totalNumberOfProducts: Int { get }
    var showSearchButton: Bool { get }
    var shouldHideAction: Bool { get }

    func viewDidAppear()
    func didDisplay(_ product: Product)
    func didSelect(_ product: Product)
    func setListStyle(_ style: ProductListingListStyle)
    func didTapAddToWishList(for product: Product, isFavorite: Bool)
}
