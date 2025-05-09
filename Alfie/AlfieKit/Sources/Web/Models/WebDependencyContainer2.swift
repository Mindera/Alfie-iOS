import Model

public final class WebDependencyContainer2 {
    let deepLinkService: DeepLinkServiceProtocol
    let webViewConfigurationService: WebViewConfigurationServiceProtocol
    let webUrlProvider: WebURLProviderProtocol

    public init(
        deepLinkService: DeepLinkServiceProtocol,
        webViewConfigurationService: WebViewConfigurationServiceProtocol,
        webUrlProvider: WebURLProviderProtocol
    ) {
        self.deepLinkService = deepLinkService
        self.webViewConfigurationService = webViewConfigurationService
        self.webUrlProvider = webUrlProvider
    }
}
