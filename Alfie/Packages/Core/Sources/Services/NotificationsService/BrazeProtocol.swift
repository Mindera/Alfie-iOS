import BrazeKit
import Foundation
import Models
import enum UIKit.UIBackgroundFetchResult
import UserNotifications

// MARK: - BrazeProtocol

public final class BrazeProtocol: BrazeProtocolService {
    private var braze: Braze?

    public init(braze: Braze? = nil) {
        self.braze = braze
    }

    public func start(_ notificationCenter: UserNotificationServiceProtocol = UserNotificationService()) {
        let configuration = Braze.Configuration(apiKey: BrazeConstants.apiKey,
                                                endpoint: BrazeConstants.endPoint)
        #if DEBUG
        configuration.logger.level = .debug
        #endif
        braze = Braze(configuration: configuration)
        notificationCenter.setNotificationCategories(categories: Braze.Notifications.categories)
        setUserID()
    }

    public func registerDevice(token: Data) {
        braze?.notifications.register(deviceToken: token)
    }

    public func receiveRemoteNotification(didReceiveRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let braze else {
            completionHandler(.noData)
            return
        }
        _ = braze.notifications.handleBackgroundNotification(userInfo: userInfo,
                                                             fetchCompletionHandler: completionHandler)
    }

    public func receiveResponse(didReceive: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        guard let braze else {
            completionHandler()
            return
        }

        _ = braze.notifications.handleUserNotification(response: didReceive,
                                                       withCompletionHandler: completionHandler)
    }

    private func setUserID() {
        braze?.changeUser(userId: BrazeConstants.userID)
        braze?.requestImmediateDataFlush()
    }
}
