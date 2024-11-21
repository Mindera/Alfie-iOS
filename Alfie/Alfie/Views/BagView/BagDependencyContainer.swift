import Core
import Models

final class BagDependencyContainer: BagDependencyContainerProtocol {
    let bagService: BagServiceProtocol
    let deepLinkService: DeepLinkServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let webViewConfigurationService: WebViewConfigurationServiceProtocol

    init(
        bagService: BagServiceProtocol,
        deepLinkService: DeepLinkServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        webViewConfigurationService: WebViewConfigurationServiceProtocol
    ) {
        self.bagService = bagService
        self.deepLinkService = deepLinkService
        self.webUrlProvider = webUrlProvider
        self.webViewConfigurationService = webViewConfigurationService
    }
}
