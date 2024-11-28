import Combine
import Foundation
import Models
import SwiftUI

public class MockProductListingViewModel: ProductListingViewModelProtocol {
    public var state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>
    public var products: [Product]
    public var wishListContent: [SelectionProduct]
    public var title: String = "Title"
    public var totalNumberOfProducts: Int
    public var style: ProductListingListStyle = .grid
    public var showSearchButton = false

    public init(
        state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>,
        products: [Product] = [],
        wishListContent: [SelectionProduct] = []
    ) {
        self.state = state
        self.products = products
        self.wishListContent = wishListContent
        totalNumberOfProducts = products.count
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidSelectCalled: ((Product) -> Void)?
    public func didSelect(_ product: Product) {
        onDidSelectCalled?(product)
    }

    public var onDidDisplayCalled: ((Product) -> Void)?
    public func didDisplay(_ product: Product) {
        onDidDisplayCalled?(product)
    }

    public var onIsFavoriteStateCalled: ((Product) -> Binding<Bool>)?
    public func isFavoriteState(for product: Product) -> Binding<Bool> {
        onIsFavoriteStateCalled?(product) ?? .init(get: { false }, set: { _ in })
    }

    public var onSetListStyleCalled: ((ProductListingListStyle) -> Void)?
    public func setListStyle(_ style: ProductListingListStyle) {
        onSetListStyleCalled?(style)
    }

    public var onDidTapAddToWishListCalled: ((Product, Bool) -> Void)?
    public func didTapAddToWishList(for product: Product, isFavorite: Bool) {
        onDidTapAddToWishListCalled?(product, isFavorite)
    }
}
