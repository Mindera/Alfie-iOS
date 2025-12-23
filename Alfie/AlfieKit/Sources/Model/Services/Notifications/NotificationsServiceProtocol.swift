import UIKit

public protocol NotificationsServiceProtocol {
    func start()
    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func application(didReceiveRemoteNotification: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func userNotificationCenter(didReceive: UNNotificationResponse, completionHandler: @escaping () -> Void)
    func userNotificationCenter(willPresent: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
}
