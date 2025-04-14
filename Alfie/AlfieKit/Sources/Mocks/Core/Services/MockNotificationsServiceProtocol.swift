import Foundation
import Model
import enum UIKit.UIBackgroundFetchResult
import UserNotifications

public final class MockNotificationsServiceProtocol: NotificationsServiceProtocol {
    public init() {}

    public var onStartCalled: (() -> Void)?
    public func start() {
        onStartCalled?()
    }

    public var onRegisterToken: ((Data) -> Void)?
    public func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        onRegisterToken?(deviceToken)
    }

    public var completionBackground: UIBackgroundFetchResult?
    public func application(didReceiveRemoteNotification _: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(completionBackground ?? .failed)
    }

    public var completiondidReceive: (() -> Void)?
    public func userNotificationCenter(didReceive _: UNNotificationResponse, completionHandler _: @escaping () -> Void) {
        completiondidReceive?()
    }

    public var completiondidwillPResent: (() -> Void)?
    public func userNotificationCenter(willPresent _: UNNotification, completionHandler _: @escaping (UNNotificationPresentationOptions) -> Void) {
        completiondidwillPResent?()
    }
}
