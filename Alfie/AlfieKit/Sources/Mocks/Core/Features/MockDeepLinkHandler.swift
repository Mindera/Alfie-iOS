import Model

public class MockDeepLinkHandler: DeepLinkHandlerProtocol {

    public init() { }
    
    public var onCanHandleDeepLinkCalled: ((DeepLink) -> Bool)?
    public func canHandleDeepLink(_ deepLink: DeepLink) -> Bool {
        onCanHandleDeepLinkCalled?(deepLink) ?? false
    }

    public var onHandleDeepLinkCalled: ((DeepLink) -> Void)?
    public func handleDeepLink(_ deepLink: DeepLink) {
        onHandleDeepLinkCalled?(deepLink)
    }
}
