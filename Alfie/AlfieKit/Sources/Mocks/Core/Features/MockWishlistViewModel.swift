import Model

public class MockWishlistViewModel: WishlistViewModelProtocol {
    public var products: [SelectedProduct]
    public var hasNavigationSeparator: Bool

    public init(products: [SelectedProduct] = [], hasNavigationSeparator: Bool = false) {
        self.products = products
        self.hasNavigationSeparator = hasNavigationSeparator
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidTapProductCalled: ((SelectedProduct) -> Void)?
    public func didTapProduct(_ selectedProduct: SelectedProduct) {
        onDidTapProductCalled?(selectedProduct)
    }

    public var onDidSelectDeleteCalled: ((SelectedProduct) -> Void)?
    public func didSelectDelete(for selectedProduct: SelectedProduct) {
        onDidSelectDeleteCalled?(selectedProduct)
    }

    public var onDidTapAddToBagCalled: ((SelectedProduct) -> Void)?
    public func didTapAddToBag(for selectedProduct: SelectedProduct) {
        onDidTapAddToBagCalled?(selectedProduct)
    }
}
