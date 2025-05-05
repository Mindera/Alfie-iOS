import Foundation

// MARK: - DeepLink

public struct DeepLink {
    public enum LinkType: Equatable {
        case unknown
        case webView(url: URL)

        // Tabs
        case home
        case shop(route: String?)
        case bag
        case wishlist
        case account

        // Screens
        case productList(category: String, query: String?, urlParameters: [String: String]?)
        case productDetail(id: String, description: String, route: String?, query: [String: String]?)

        public func configurationKey() -> ConfigurationKey? {
            // In case a link type depends on a specific feature toggle to be enabled, return the key here
            // swiftlint:disable vertical_whitespace_between_cases
            switch self {
            case .wishlist:
                return .wishlist
            default:
                return nil
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }

    public let type: LinkType
    public let fullUrl: URL
    let language: String?
    let country: String?

    public init(type: LinkType, fullUrl: URL, language: String? = nil, country: String? = nil) {
        self.type = type
        self.fullUrl = fullUrl
        self.language = language
        self.country = country
    }
}

extension DeepLink.LinkType {
    public var isWebView: Bool {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .productList,
             .productDetail, // swiftlint:disable:this indentation_width
             .bag,
             .shop,
             .home,
             .wishlist,
             .account:
            return false
        default:
            return true
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
