import AlicerceLogging
import Foundation
import Models

public final class DeepLinkService: DeepLinkServiceProtocol {
    private var handlers: [DeepLinkHandlerProtocol]
    private let parsers: [DeepLinkParserProtocol]
    private let linkConfiguration: LinkConfigurationProtocol
    private let log: Logger

    public init(
        parsers: [DeepLinkParserProtocol],
        handlers: [DeepLinkHandlerProtocol] = [],
        configuration: LinkConfigurationProtocol,
        log: Logger
    ) {
        self.parsers = parsers
        self.handlers = handlers
        self.linkConfiguration = configuration
        self.log = log
    }

    // MARK: - DeepLinkServiceProtocol

    public func update(handlers: [DeepLinkHandlerProtocol]) {
        self.handlers = handlers
    }

    public func deepLinkType(_ url: URL) -> DeepLink.LinkType? {
        deepLinkFromUrl(url)?.type
    }

    public func deepLink(from url: URL) -> DeepLink? {
        deepLinkFromUrl(url)
    }

    public func canHandleUrl(_ url: URL) -> Bool {
        guard let deepLink = deepLinkFromUrl(url) else {
            return false
        }

        return handlers.contains { $0.canHandleDeepLink(deepLink) }
    }

    public func openUrls(_ urls: [URL]) {
        // For now, support only opening one URL at a time
        guard let url = urls.first else {
            return
        }

        guard let deepLink = deepLinkFromUrl(url) else {
            log.warning("Could not create valid deeplink from URL \(url), creating fallback to open in webview")
            let fallbackLink = DeepLink(type: .webView(url: url), fullUrl: url)
            handleDeepLink(fallbackLink)
            return
        }

        handleDeepLink(deepLink)
    }

    // MARK: - Private

    private func handleDeepLink(_ deepLink: DeepLink) {
        guard let handler = handlers.first(where: { $0.canHandleDeepLink(deepLink) }) else {
            log.info("No handlers can handle deeplink \(deepLink), ignoring")
            return
        }

        // For now ignore .unknown deep links
        guard deepLink.type != .unknown else {
            return
        }

        log.debug("Handler \(handler) will handle deeplink \(deepLink)")
        handler.handleDeepLink(deepLink)
    }

    private func deepLinkFromUrl(_ url: URL) -> DeepLink? {
        for parser in parsers {
            if let parsedLink = parser.parseUrl(url) {
                return parsedLink
            }
        }

        return nil
    }
}
