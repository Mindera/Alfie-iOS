import AlicerceLogging
import Core
import Foundation
import Model

public extension DeepLinkService {
    convenience init(configuration: LinkConfigurationProtocol, log: Logger) {
        let parsers: [DeepLinkParserProtocol] = [
            InternalDeepLinkParser(configuration: configuration),
            ProductListingDeepLinkParser(configuration: configuration),
            ProductDetailsDeepLinkParser(configuration: configuration),
            DefaultDeepLinkParser(configuration: configuration),
        ] // Order is important!
        self.init(parsers: parsers, configuration: configuration, log: log)
    }
}
