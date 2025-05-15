import Model
import Foundation

public final class MockDeepLinkService: DeepLinkServiceProtocol {
    public init() { }

    public var onUpdateAvailabilityOfHandlersCalled: ((Bool) -> Void)?
    public func updateAvailabilityOfHandlers(to availability: Bool) {
        onUpdateAvailabilityOfHandlersCalled?(availability)
    }

    public var onUpdateHandlersCalled: (([DeepLinkHandlerProtocol]) -> Void)?
    public func update(handlers: [DeepLinkHandlerProtocol]) {
        onUpdateHandlersCalled?(handlers)
    }

    public var onDeepLinkTypeCalled: ((URL) -> DeepLink.LinkType?)?
    public func deepLinkType(_ url: URL) -> DeepLink.LinkType? {
        onDeepLinkTypeCalled?(url)
    }

    public var onCanHandleUrlCalled: ((URL) -> Bool)?
    public func canHandleUrl(_ url: URL) -> Bool {
        onCanHandleUrlCalled?(url) ?? false
    }

    public var onOpenUrlsCalled: (([URL]) -> Void)?
    public func openUrls(_ urls: [URL]) {
        onOpenUrlsCalled?(urls)
    }
}
