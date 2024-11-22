import BrazeKit
import Common
import Core
import Foundation
import Models
import StyleGuide
import UIKit
#if DEBUG
import Mocks
#endif

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppDelegateProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    private(set) static var instance: AppDelegate! = nil
    var serviceProvider: ServiceProviderProtocol!
    var tabCoordinator: TabCoordinator!
    // swiftlint:enable implicitly_unwrapped_optional
    static var braze: Braze?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.instance = self
        bootstrap(application: application)
        return true
    }

    // MARK: - AppDelegateProtocol

    public func rebootApp() {
        // Reset services and any other managers that need to be gracefuly terminated before the app reboots
        serviceProvider.resetServices()
        tabCoordinator.removeCoordinatedViews()

        // Recreate services
        bootstrap(application: nil)

        // Recreate UI
        AppState.shared.sessionID = UUID()
    }

    // MARK: - Private

    private func bootstrap(application: UIApplication?) {
        if ProcessInfo.isSwiftUIPreview || ProcessInfo.isRunningTests {
        #if DEBUG
            serviceProvider = MockServiceProvider()
        #endif
        } else {
            CoreBootstrap.bootstrap()
            serviceProvider = ServiceProvider()
            if let application {
                application.registerForRemoteNotifications()
                serviceProvider.notificationsService.start()
            }
        }

        var tabs: [TabScreen] = TabScreen.allCases

        // TODO: Review feature toggle flow
        if !serviceProvider.configurationService.isFeatureEnabled(.wishlist) {
            tabs.removeAll { $0 == .wishlist }
        }

        tabCoordinator = TabCoordinator(tabs: tabs, activeTab: .home(), serviceProvider: serviceProvider)
    }

    // MARK: - Notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        serviceProvider.notificationsService.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        serviceProvider.notificationsService.application(
            didReceiveRemoteNotification: userInfo,
            completionHandler: completionHandler
        )
    }

    func userNotificationCenter(_ application: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        serviceProvider.notificationsService.userNotificationCenter(
            didReceive: response,
            completionHandler: completionHandler
        )
    }

    func userNotificationCenter(_ notificationCenter: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        serviceProvider.notificationsService.userNotificationCenter(
            willPresent: willPresent,
            completionHandler: completionHandler
        )
    }
}
