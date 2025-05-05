import Foundation

public protocol DeepLinkHandlerProtocol {
    func canHandleDeepLink(_ deepLink: DeepLink) -> Bool
    func handleDeepLink(_ deepLink: DeepLink)
}
