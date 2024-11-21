import Foundation

public protocol BagDependencyContainerProtocol {
    var bagService: BagServiceProtocol { get }
    var deepLinkService: DeepLinkServiceProtocol { get }
    var webUrlProvider: WebURLProviderProtocol { get }
    var webViewConfigurationService: WebViewConfigurationServiceProtocol { get }
}
