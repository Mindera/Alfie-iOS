import Foundation
import Model
import RegexBuilder
import Utils

final class ProductDetailsDeepLinkParser: DeepLinkParserProtocol {
    let configuration: LinkConfigurationProtocol

    private enum Constants {
        static let urlPrefixRegex = /\/product\//.ignoresCase()
        static let routePrefixRegex = "nav="
        static let routeRegex = ZeroOrMore(.digit)
    }

    // MARK: Regex Components

    /// Captures everything after the `/product/` prefix as the Handle, used as-is — the BFF resolves a
    /// product by its Handle, so there is nothing else to extract. Handles are platform-shaped: a Shopify
    /// Handle is a single segment, whereas a BigCommerce Handle is a site route path and routinely contains
    /// `/`. Capturing the whole remaining path keeps both kinds intact, with no segments dropped.
    ///
    /// The cost is that a deeper path under `/product/` is no longer distinguishable from a multi-segment
    /// Handle, so a sub-resource page (e.g. `/product/<handle>/reviews`) now resolves as a Handle rather
    /// than falling through to the web view. That ambiguity is inherent once a Handle may contain `/`; the
    /// BFF failing to resolve the Handle is the backstop.
    private let urlRegex = Regex {
        Constants.urlPrefixRegex
        Capture {
            OneOrMore(.anyNonNewline)
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

        // `path()` keeps percent-encoding, so the Handle travels onward exactly as it appeared in the link
        // and reaches the BFF verbatim. Sibling parsers use `cleanPathComponents`, which decodes; the two
        // only diverge for a non-ASCII Handle, and matching the link byte-for-byte is what a lookup by
        // route path wants. The corollary is that a Handle carrying a literal `%2F` is not representable —
        // it would arrive as a separator. Nothing needs one, now that a Handle may contain `/` unescaped.
        guard
            let productMatch = url.path().wholeMatch(of: urlRegex),
            let handle = Self.handle(from: productMatch.output.1)
        else {
            return nil
        }
        let navigationRoute = url.query().flatMap { extractRoute(from: $0) }
        let normalisedWebUrl = url.httpSecureUrl(using: configuration)
        return .init(
            type: .productDetail(
                handle: handle,
                route: navigationRoute,
                query: url.queryParameters
            ),
            fullUrl: normalisedWebUrl
        )
    }

    /// Drops every trailing separator, so `/product/<handle>/` now resolves to the same Handle as
    /// `/product/<handle>` — previously such a link fell through to the web view. Without this, the trailing
    /// `/` would travel to the BFF as part of the Handle: the BFF prepends a leading separator when one is
    /// missing but never trims a trailing one, so the lookup would simply fail to resolve.
    /// Returns `nil` when only separators follow the prefix, so such a link still falls through to the web view.
    private static func handle(from capturedPath: String) -> String? {
        var handle = capturedPath
        while handle.hasSuffix("/") {
            handle.removeLast()
        }
        return handle.isEmpty ? nil : handle
    }

    /// Returns optional navigation route
    private func extractRoute(from query: String) -> String? {
        query.firstMatch(of: productRouteRegex)?.output.1
    }
}
