import Model

public class MockWishlistViewModel: WishlistViewModelProtocol {
    public var state: ViewState<[SelectedProduct], Never>
    public var hasNavigationSeparator: Bool

    public init(state: ViewState<[SelectedProduct], Never> = .success([]), hasNavigationSeparator: Bool = false) {
        self.state = state
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
