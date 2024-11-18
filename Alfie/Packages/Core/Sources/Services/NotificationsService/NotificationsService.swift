import Foundation
import Models
import UIKit
import UserNotifications

public final class NotificationsService: NSObject, NotificationsServiceProtocol, UNUserNotificationCenterDelegate {
    let braze: BrazeProtocolService
    let notificationCenter: UserNotificationServiceProtocol

    public init(
        braze: BrazeProtocolService = BrazeProtocol(),
        notificationCenter: UserNotificationServiceProtocol = UserNotificationService()
    ) {
        self.braze = braze
        self.notificationCenter = notificationCenter
    }

    public func start() {
        braze.start(notificationCenter)
        notificationCenter.setDelegate(delegate: self)
        notificationCenter.requestAuthorization(options: NotificationConstants.options) { _, _ in }
    }

    public func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        braze.registerDevice(token: deviceToken)
    }

    public func application(didReceiveRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        braze.receiveRemoteNotification(didReceiveRemoteNotification: userInfo, completionHandler: completionHandler)
    }

    public func userNotificationCenter(didReceive: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        braze.receiveResponse(didReceive: didReceive, completionHandler: completionHandler)
    }

    public func userNotificationCenter(willPresent _: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }

    enum NotificationConstants {
        static var options: UNAuthorizationOptions = [.sound, .alert, .badge]
    }
}
