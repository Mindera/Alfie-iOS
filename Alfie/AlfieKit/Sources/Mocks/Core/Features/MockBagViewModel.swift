import Model

public class MockBagViewModel: BagViewModelProtocol {
    public var state: ViewState<Cart?, BFFRequestError>
    public var transientFailure: BFFRequestError.BFFRequestErrorType?

    public init(
        state: ViewState<Cart?, BFFRequestError> = .success(nil),
        transientFailure: BFFRequestError.BFFRequestErrorType? = nil
    ) {
        self.state = state
        self.transientFailure = transientFailure
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

    public var onDidSelectLineCalled: ((CartLine) -> Void)?
    public func didSelectLine(_ line: CartLine) {
        onDidSelectLineCalled?(line)
    }

    public var onDidDismissTransientFailureCalled: (() -> Void)?
    public func didDismissTransientFailure() {
        onDidDismissTransientFailureCalled?()
    }
}
