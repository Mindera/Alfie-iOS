import Foundation
import Model

final class InternalDeepLinkParser: DeepLinkParserProtocol {
    let configuration: LinkConfigurationProtocol

    init(configuration: LinkConfigurationProtocol) {
        self.configuration = configuration
    }

    // MARK: - DeepLinkParserProtocol

    func parseUrl(_ url: URL) -> DeepLink? {
        guard configuration.isURLSupported(url), url.scheme == "alfie" else {
            return nil
        }

        let path = url.cleanPath
        if path == ThemedURL.brands.path {
            return DeepLink(type: .shop(route: ThemedURL.brands.path), fullUrl: url)
        } else if path == ThemedURL.services.path {
            return DeepLink(type: .shop(route: ThemedURL.services.path), fullUrl: url)
        } else if path == ThemedURL.shop.path {
            return DeepLink(type: .shop(route: ThemedURL.shop.path), fullUrl: url)
        } else {
            return nil
        }
    }
}
