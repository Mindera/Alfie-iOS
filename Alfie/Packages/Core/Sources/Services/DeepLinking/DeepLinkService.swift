import Foundation
import Models
import Common

public final class DeepLinkService: DeepLinkServiceProtocol {
    private var handlers: [DeepLinkHandlerProtocol]
    private let parsers: [DeepLinkParserProtocol]
    private let linkConfiguration: LinkConfigurationProtocol

    public init(parsers: [DeepLinkParserProtocol],
                handlers: [DeepLinkHandlerProtocol] = [],
                configuration: LinkConfigurationProtocol) {
        self.parsers = parsers
        self.handlers = handlers
        self.linkConfiguration = configuration
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

        return handlers.contains(where: { $0.canHandleDeepLink(deepLink) })
    }

    public func openUrls(_ urls: [URL]) {
        // For now, support only opening one URL at a time
        guard let url = urls.first else {
            return
        }

        guard let deepLink = deepLinkFromUrl(url) else {
            logWarning("Could not create valid deeplink from URL \(url), creating fallback to open in webview")
            let fallbackLink = DeepLink(type: .webView(url: url), fullUrl: url)
            handleDeepLink(fallbackLink)
            return
        }

        handleDeepLink(deepLink)
    }

    // MARK: - Private

    private func handleDeepLink(_ deepLink: DeepLink) {
        guard let handler = handlers.first(where: { $0.canHandleDeepLink(deepLink) }) else {
            log("No handlers can handle deeplink \(deepLink), ignoring", level: .info)
            return
        }

        // For now ignore .unknown deep links
        guard deepLink.type != .unknown else {
            return
        }

        log("Handler \(handler) will handle deeplink \(deepLink)", level: .debug, printToConsole: false)
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
