import Core
import Foundation
import Models

extension DeepLinkService {
    convenience init(configuration: LinkConfigurationProtocol) {
        let parsers: [DeepLinkParserProtocol] = [
            InternalDeepLinkParser(configuration: configuration),
            ProductListingDeepLinkParser(configuration: configuration),
            ProductDetailsDeepLinkParser(configuration: configuration),
            DefaultDeepLinkParser(configuration: configuration),
        ] // Order is important!
        self.init(
            parsers: parsers,
            configuration: configuration,
            log: log
        )
    }
}
