import Models

final class WebDependencyContainer {
    let deepLinkService: DeepLinkServiceProtocol
    let webViewConfigurationService: WebViewConfigurationServiceProtocol
    let webUrlProvider: WebURLProviderProtocol

    init(
        deepLinkService: DeepLinkServiceProtocol,
        webViewConfigurationService: WebViewConfigurationServiceProtocol,
        webUrlProvider: WebURLProviderProtocol
    ) {
        self.deepLinkService = deepLinkService
        self.webViewConfigurationService = webViewConfigurationService
        self.webUrlProvider = webUrlProvider
    }
}
