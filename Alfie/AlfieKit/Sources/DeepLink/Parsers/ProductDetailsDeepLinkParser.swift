import AlicerceLogging
import Foundation
import Model
import RegexBuilder
import Utils

final class ProductDetailsDeepLinkParser: DeepLinkParserProtocol {
    let configuration: LinkConfigurationProtocol
    private let log: Logger

    private enum Constants {
        static let urlPrefixRegex = /\/product\//.ignoresCase()
        static let routePrefixRegex = "nav="
        static let routeRegex = ZeroOrMore(.digit)
    }

    // MARK: Regex Components

    /// Captures the whole `/product/<slug>` path segment as the BFF handle. The slug is used as-is — the
    /// BFF resolves a product by its slug, so there is nothing else to extract.
    private let urlRegex = Regex {
        Constants.urlPrefixRegex
        Capture {
            OneOrMore(.any)
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

    init(configuration: LinkConfigurationProtocol, log: Logger) {
        self.configuration = configuration
        self.log = log
    }

    func parseUrl(_ url: URL) -> DeepLink? {
        guard configuration.isURLSupported(url) else {
            log.debug("[PDP deeplink] '\(url.absoluteString)' rejected: scheme/host not supported")
            return nil
        }

        guard let productMatch = url.path().wholeMatch(of: urlRegex) else {
            log.debug("[PDP deeplink] path '\(url.path())' is not a /product/<slug> link (falls through to webView)")
            return nil
        }
        let slug = productMatch.output.1
        let navigationRoute = url.query().flatMap { extractRoute(from: $0) }
        let normalisedWebUrl = url.httpSecureUrl(using: configuration)
        log.debug("[PDP deeplink] matched: slug='\(slug)'")
        return .init(
            type: .productDetail(
                slug: slug,
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
