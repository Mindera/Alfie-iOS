import Foundation

public protocol BagDependencyContainerProtocol {
    var deepLinkService: DeepLinkServiceProtocol { get }
    var webUrlProvider: WebURLProviderProtocol { get }
    var webViewConfigurationService: WebViewConfigurationServiceProtocol { get }
}
