import Models

public class MockBagDependencyContainer: BagDependencyContainerProtocol {
    public var deepLinkService: DeepLinkServiceProtocol
    public var webUrlProvider: WebURLProviderProtocol
    public var webViewConfigurationService: WebViewConfigurationServiceProtocol

    public init(deepLinkService: DeepLinkServiceProtocol = MockDeepLinkService(),
                webUrlProvider: WebURLProviderProtocol = MockWebUrlProvider(),
                webViewConfigurationService: WebViewConfigurationServiceProtocol = MockWebViewConfigurationService()) {
        self.deepLinkService = deepLinkService
        self.webUrlProvider = webUrlProvider
        self.webViewConfigurationService = webViewConfigurationService
    }
}
