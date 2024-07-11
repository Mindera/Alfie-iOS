import Foundation
import Models

public class MockWebDependencyContainer: WebDependencyContainerProtocol {
    public var deepLinkService: DeepLinkServiceProtocol
    public var webViewConfigurationService: WebViewConfigurationServiceProtocol
    public var webUrlProvider: WebURLProviderProtocol

    public init(deepLinkService: DeepLinkServiceProtocol = MockDeepLinkService(),
                webViewConfigurationService: WebViewConfigurationServiceProtocol = MockWebViewConfigurationService(),
                webUrlProvider: WebURLProviderProtocol = MockWebUrlProvider()) {
        self.deepLinkService = deepLinkService
        self.webViewConfigurationService = webViewConfigurationService
        self.webUrlProvider = webUrlProvider
    }
}
