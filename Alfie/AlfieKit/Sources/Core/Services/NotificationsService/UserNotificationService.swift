import Foundation
import Model
import UserNotifications

public final class UserNotificationService: UserNotificationServiceProtocol {
    public init() {}

    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, (any Error)?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: completionHandler)
    }

    public func setNotificationCategories(categories: Set<UNNotificationCategory>) {
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }

    public func setDelegate(delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
    }
}
