import Foundation
import Models
import UserNotifications

public final class MockUserNotificationService: UserNotificationServiceProtocol {
    public init(options: UNAuthorizationOptions? = nil, categories: Set<UNNotificationCategory>? = nil) {
        self.options = options
        self.categories = categories
    }

    public func setDelegate(delegate _: any UNUserNotificationCenterDelegate) {}

    public var options: UNAuthorizationOptions?
    public func requestAuthorization(options: UNAuthorizationOptions, completionHandler _: @escaping (Bool, (any Error)?) -> Void) {
        self.options = options
    }

    public var categories: Set<UNNotificationCategory>?
    public func setNotificationCategories(categories: Set<UNNotificationCategory>) {
        self.categories = categories
    }
}
