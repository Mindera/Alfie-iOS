import Models

public class MockBagDependencyContainer: BagDependencyContainerProtocol {
    public var bagService: BagServiceProtocol
    public var deepLinkService: DeepLinkServiceProtocol
    public var webUrlProvider: WebURLProviderProtocol
    public var webViewConfigurationService: WebViewConfigurationServiceProtocol

    public init(
        bagService: BagServiceProtocol = MockBagService(),
        deepLinkService: DeepLinkServiceProtocol = MockDeepLinkService(),
        webUrlProvider: WebURLProviderProtocol = MockWebUrlProvider(),
        webViewConfigurationService: WebViewConfigurationServiceProtocol = MockWebViewConfigurationService()
    ) {
        self.bagService = bagService
        self.deepLinkService = deepLinkService
        self.webUrlProvider = webUrlProvider
        self.webViewConfigurationService = webViewConfigurationService
    }
}
