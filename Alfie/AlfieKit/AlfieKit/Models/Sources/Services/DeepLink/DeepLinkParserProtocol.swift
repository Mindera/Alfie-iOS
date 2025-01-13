import Foundation

public protocol DeepLinkParserProtocol {
    var configuration: LinkConfigurationProtocol { get }

    func parseUrl(_ url: URL) -> DeepLink?
}
