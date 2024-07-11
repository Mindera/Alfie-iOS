import Models

public class MockBagViewModel: BagViewModelProtocol {
    public init() {}

    public var onWebViewModelCalled: (() -> any WebViewModelProtocol)?
    public func webViewModel() -> any WebViewModelProtocol {
        onWebViewModelCalled?() ?? MockWebViewModel()
    }
}
