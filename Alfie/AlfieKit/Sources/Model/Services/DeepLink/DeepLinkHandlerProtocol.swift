import Foundation

public protocol DeepLinkHandlerProtocol: AnyObject {
    var isReadyToHandleLinks: Bool { get set }

    func canHandleDeepLink(_ deepLink: DeepLink) -> Bool
    func handleDeepLink(_ deepLink: DeepLink)
}
