import Foundation
import Models

final class DefaultDeepLinkParser: DeepLinkParserProtocol {
    private enum PathComponents: String {
        case home
        case shop
        case wishlist
        case account
        case bag

        // Special Shop cases
        case shopBrands = "brand"
        case shopServices = "services/store-services"
    }

    let configuration: LinkConfigurationProtocol

    init(configuration: LinkConfigurationProtocol) {
        self.configuration = configuration
    }

    // MARK: - DeepLinkParserProtocol

    func parseUrl(_ url: URL) -> DeepLink? {
        guard configuration.isURLSupported(url) else {
            return DeepLink(type: .unknown, fullUrl: url)
        }

        let path = url.cleanPath.lowercased()

        // Shop cases
        // swiftlint:disable vertical_whitespace_between_cases
        switch path {
        case PathComponents.shopBrands.rawValue:
            return .init(type: .shop(route: ThemedURL.brands.path), fullUrl: url)
        case PathComponents.shopServices.rawValue:
            return .init(type: .shop(route: ThemedURL.services.path), fullUrl: url)
        default:
            break
        }
        // swiftlint:enable vertical_whitespace_between_cases

        let components = url.cleanPathComponents

        guard let component = components.first else {
            return .init(type: .home, fullUrl: url)
        }

        switch component {
        case PathComponents.home.rawValue:
            return .init(type: .home, fullUrl: url)

        case PathComponents.shop.rawValue:
            return .init(type: .shop(route: nil), fullUrl: url)

        case PathComponents.bag.rawValue:
            return .init(type: .bag, fullUrl: url)

        case PathComponents.wishlist.rawValue:
            return .init(type: .wishlist, fullUrl: url)

        case PathComponents.account.rawValue:
            return .init(type: .account, fullUrl: url)

        default:
            let normalisedWebUrl = url.httpSecureUrl(using: configuration)
            return DeepLink(type: .webView(url: normalisedWebUrl), fullUrl: url)
        }
    }
}
