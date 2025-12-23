import Foundation
import Model
import enum UIKit.UIBackgroundFetchResult
import UserNotifications

public final class MockBrazeProtocolService: BrazeProtocolService {
    public init() {}

    public var startCalledCount = 0
    public func start(_: UserNotificationServiceProtocol) {
        startCalledCount += 1
    }

    public var tokenReceived: Data?
    public func registerDevice(token: Data) {
        tokenReceived = token
    }

    public var backgroundFetchResponse: UIBackgroundFetchResult?
    public var userInfoReceived: [AnyHashable: Any]?
    public func receiveRemoteNotification(didReceiveRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        userInfoReceived = userInfo
        completionHandler(backgroundFetchResponse ?? .noData)
    }

    public var responseReceived: UNNotificationResponse?
    public func receiveResponse(didReceive: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        responseReceived = didReceive
        completionHandler()
    }
}
