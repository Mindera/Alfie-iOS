import Foundation
import UserNotifications
import enum UIKit.UIBackgroundFetchResult

// MARK: - BrazeProtocolService

public protocol BrazeProtocolService {
    func start(_ notificationCenter: UserNotificationServiceProtocol)
    func registerDevice(token: Data)
    func receiveRemoteNotification(didReceiveRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func receiveResponse(didReceive: UNNotificationResponse, completionHandler: @escaping () -> Void)
}
