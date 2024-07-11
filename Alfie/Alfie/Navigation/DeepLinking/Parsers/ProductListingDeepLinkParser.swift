import Foundation
import Models

final class ProductListingDeepLinkParser: DeepLinkParserProtocol {
    private enum PathComponents: String, CaseIterable {
        case designer
        case sale
        case women
        case men
        case shoes
        case bags = "bags-and-accessories"
        case beauty
        case kids
        case home = "home-and-food"
        case electrical
    }

    private let brandComponent = "brand"
    let configuration: LinkConfigurationProtocol

    init(configuration: LinkConfigurationProtocol) {
        self.configuration = configuration
    }

    // MARK: - DeepLinkParserProtocol

    func parseUrl(_ url: URL) -> DeepLink? {
        guard configuration.isURLSupported(url) else {
            return nil
        }

        let normalisedWebUrl = url.httpSecureUrl(using: configuration)
        let components = url.cleanPathComponents

        // Special "Brand" case, check if it is /Brand/<something>, in that case it's a PLP link, otherwise let the default parser handle it
        if let firstComponent = components.first?.lowercased(),
           firstComponent == brandComponent,
           components.count == 2,
           let _ = components.last?.lowercased() {
            return .init(type: .productList(category: url.cleanPath, query: nil, urlParameters: url.queryParameters), fullUrl: normalisedWebUrl)
        }

        guard
            let component = components.first?.lowercased(),
            PathComponents.allCases.contains(where: { $0.rawValue == component })
        else {
            return nil
        }

        return .init(type: .productList(category: url.cleanPath, query: nil, urlParameters: url.queryParameters), fullUrl: normalisedWebUrl)
    }
}
