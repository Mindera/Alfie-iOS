import Core
import Models

final class BagDependencyContainer: BagDependencyContainerProtocol {
    let deepLinkService: DeepLinkServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let webViewConfigurationService: WebViewConfigurationServiceProtocol

    init(deepLinkService: DeepLinkServiceProtocol,
         webUrlProvider: WebURLProviderProtocol,
         webViewConfigurationService: WebViewConfigurationServiceProtocol) {
        self.deepLinkService = deepLinkService
        self.webUrlProvider = webUrlProvider
        self.webViewConfigurationService = webViewConfigurationService
    }
}
