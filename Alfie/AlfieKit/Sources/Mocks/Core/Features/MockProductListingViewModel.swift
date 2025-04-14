import Combine
import Foundation
import Model
import SwiftUI

public class MockProductListingViewModel: ProductListingViewModelProtocol {
    public var state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>
    public var products: [Product]
    public var wishlistContent: [SelectedProduct]
    public var title: String = "Title"
    public var totalNumberOfProducts: Int
    public var style: ProductListingListStyle = .grid
    public var sortOption: String?
    public var showSearchButton = false
    public var showRefine: Bool = false

    public init(
        state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>,
        products: [Product] = [],
        wishlistContent: [SelectedProduct] = []
    ) {
        self.state = state
        self.products = products
        self.wishlistContent = wishlistContent
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

    public var onIsFavoriteStateCalled: ((Product) -> Bool)?
    public func isFavoriteState(for product: Product) -> Bool {
        onIsFavoriteStateCalled?(product) ?? false
    }

    public var onSetListStyleCalled: ((ProductListingListStyle) -> Void)?
    public func setListStyle(_ style: ProductListingListStyle) {
        onSetListStyleCalled?(style)
    }

    public var onDidTapAddToWishlistCalled: ((Product, Bool) -> Void)?
    public func didTapAddToWishlist(for product: Product, isFavorite: Bool) {
        onDidTapAddToWishlistCalled?(product, isFavorite)
    }

    public var onDidApplyFiltersCalled: (() -> Void)?
    public func didApplyFilters() {
        onDidApplyFiltersCalled?()
    }
}
