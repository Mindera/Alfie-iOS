import Combine
import Foundation
import Models

public class MockProductListingViewModel: ProductListingViewModelProtocol {
    public var state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>
    public var products: [Product]
    public var title: String = "Title"
    public var totalNumberOfProducts: Int
    public var style: ProductListingListStyle = .grid
    public var showSearchButton = false

    public init(state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>,
                products: [Product] = []) {
        self.state = state
        self.products = products
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

    public var onSetListStyleCalled: ((ProductListingListStyle) -> Void)?
    public func setListStyle(_ style: ProductListingListStyle) {
        onSetListStyleCalled?(style)
    }
}
