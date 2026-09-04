import Model

public class MockBagViewModel: BagViewModelProtocol {
    public var state: ViewState<Cart?, BFFRequestError>
    public var isWishlistEnabled: Bool = false
    public var removalFailure: BFFRequestError.BFFRequestErrorType?

    public init(
        state: ViewState<Cart?, BFFRequestError> = .success(nil),
        removalFailure: BFFRequestError.BFFRequestErrorType? = nil
    ) {
        self.state = state
        self.removalFailure = removalFailure
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidTapRetryCalled: (() -> Void)?
    public func didTapRetry() {
        onDidTapRetryCalled?()
    }

    public var onDidSelectDeleteCalled: ((CartLine) -> Void)?
    public func didSelectDelete(_ line: CartLine) {
        onDidSelectDeleteCalled?(line)
    }

    public var onDidDismissRemovalFailureCalled: (() -> Void)?
    public func didDismissRemovalFailure() {
        onDidDismissRemovalFailureCalled?()
    }

    public var onDidTapMyAccountCalled: (() -> Void)?
    public func didTapMyAccount() {
        onDidTapMyAccountCalled?()
    }

    public var onDidTapWishlistCalled: (() -> Void)?
    public func didTapWishlist() {
        onDidTapWishlistCalled?()
    }
}
