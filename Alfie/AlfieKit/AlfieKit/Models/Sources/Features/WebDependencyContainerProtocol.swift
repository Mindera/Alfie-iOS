import Foundation

public protocol WebDependencyContainerProtocol {
    var deepLinkService: DeepLinkServiceProtocol { get }
    var webUrlProvider: WebURLProviderProtocol { get }
    var webViewConfigurationService: WebViewConfigurationServiceProtocol { get }
}
