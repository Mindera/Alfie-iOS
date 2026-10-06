import Model

public class MockWishlistViewModel: WishlistViewModelProtocol {
    public var state: ViewState<[SelectedProduct], Never>
    public var undoableRemoval: WishlistRemoval?
    public var hasNavigationSeparator: Bool

    public init(
        state: ViewState<[SelectedProduct], Never> = .success([]),
        undoableRemoval: WishlistRemoval? = nil,
        hasNavigationSeparator: Bool = false
    ) {
        self.state = state
        self.undoableRemoval = undoableRemoval
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

    public var onDidTapUndoRemovalCalled: (() -> Void)?
    public func didTapUndoRemoval() {
        onDidTapUndoRemovalCalled?()
    }

    public var onDidDismissRemovalSnackbarCalled: (() -> Void)?
    public func didDismissRemovalSnackbar() {
        onDidDismissRemovalSnackbarCalled?()
    }
}
