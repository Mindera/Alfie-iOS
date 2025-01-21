import Foundation
import Models

public class MockDeepLinkParser: DeepLinkParserProtocol {
    public var configuration: LinkConfigurationProtocol

    public init(configuration: LinkConfigurationProtocol,
                onParseUrlCalled: ( (URL) -> DeepLink?)? = nil) {
        self.configuration = configuration
        self.onParseUrlCalled = onParseUrlCalled
    }

    public var onParseUrlCalled: ((URL) -> DeepLink?)?
    public func parseUrl(_ url: URL) -> DeepLink? {
        onParseUrlCalled?(url) ?? nil
    }
}
