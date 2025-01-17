import Foundation
import UserNotifications

public protocol UserNotificationServiceProtocol {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, (any Error)?) -> Void)
    func setNotificationCategories(categories: Set<UNNotificationCategory>)
    func setDelegate(delegate: UNUserNotificationCenterDelegate)
}
