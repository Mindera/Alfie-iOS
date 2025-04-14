import Foundation
import Model
import RegexBuilder

final class ProductDetailsDeepLinkParser: DeepLinkParserProtocol {
    let configuration: LinkConfigurationProtocol

    private enum Constants {
        static let urlPrefixRegex = /\/product\//.ignoresCase()
        static let productDescriptionRegex = ZeroOrMore(.any)
        static let productIdLength = 8
        static let routePrefixRegex = "nav="
        static let routeRegex = ZeroOrMore(.digit)
    }

    // MARK: Regex Components

    private let urlRegex = Regex {
        Constants.urlPrefixRegex
        productRegex
    }

    private static let productRegex = Regex {
        /// product description
        Capture {
            Constants.productDescriptionRegex
        } transform: {
            String($0)
        }
        /// product id
        TryCapture {
            Repeat(Constants.productIdLength...Constants.productIdLength) {
                .digit
            }
        } transform: {
            String($0)
        }
    }

    private let productRouteRegex = Regex {
        Constants.routePrefixRegex
        /// navigation route
        Capture {
            Constants.routeRegex
        } transform: {
            String($0)
        }
    }

    init(configuration: LinkConfigurationProtocol) {
        self.configuration = configuration
    }

    func parseUrl(_ url: URL) -> DeepLink? {
        guard configuration.isURLSupported(url) else {
            return nil
        }

        guard let productMatch = url.path().wholeMatch(of: urlRegex) else {
            return nil
        }
        let productDescription = productMatch.output.1
        let productId = productMatch.output.2
        let navigationRoute = url.query().flatMap { extractRoute(from: $0) }
        let normalisedWebUrl = url.httpSecureUrl(using: configuration)
        return .init(
            type: .productDetail(
                id: productId,
                description: productDescription,
                route: navigationRoute,
                query: url.queryParameters
            ),
            fullUrl: normalisedWebUrl
        )
    }

    /// Returns optional navigation route
    private func extractRoute(from query: String) -> String? {
        query.firstMatch(of: productRouteRegex)?.output.1
    }
}
