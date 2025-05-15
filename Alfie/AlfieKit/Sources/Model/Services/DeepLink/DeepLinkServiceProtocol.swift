import Foundation

public protocol DeepLinkServiceProtocol {
    func updateAvailabilityOfHandlers(to availability: Bool)
    func update(handlers: [DeepLinkHandlerProtocol])
    func deepLinkType(_ url: URL) -> DeepLink.LinkType?
    func canHandleUrl(_ url: URL) -> Bool
    func openUrls(_ urls: [URL])
}
