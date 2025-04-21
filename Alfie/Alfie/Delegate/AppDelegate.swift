import AlicerceLogging
import BrazeKit
import Combine
import Core
import Foundation
import Model
import os.log
import SharedUI
import UIKit
import Utils
#if DEBUG
import Mocks
#endif

// swiftlint:disable implicitly_unwrapped_optional
private(set) var log: AlicerceLogging.Logger!

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppDelegateProtocol {
    private enum Constants {
        static let defaultBundleID = "com.mindera.alfie"
        static let consoleLoggerCategory = "console"
    }

    private(set) static var instance: AppDelegate! = nil
    var serviceProvider: ServiceProviderProtocol!
    var tabCoordinator: TabCoordinator!
    // swiftlint:enable implicitly_unwrapped_optional
    static var braze: Braze?

    private var featureAvailabilitySubscription: AnyCancellable?
    private var isWishlistEnabled = false
    private var isStoreServicesEnabled = false

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
            Alfie.log = Log.DummyLogger()
            #endif
        } else {
            Alfie.log = createLogger()
            CoreBootstrap.bootstrapFirebaseApp(log: log)
            StyleGuideLogger.set(logger: log)
            serviceProvider = ServiceProvider()
            if let application {
                application.registerForRemoteNotifications()
                serviceProvider.notificationsService.start()
            }
        }

        var tabs: [TabScreen] = [.home(), .shop(), .bag]

        isWishlistEnabled = serviceProvider.configurationService.isFeatureEnabled(.wishlist)
        isStoreServicesEnabled = serviceProvider.configurationService.isFeatureEnabled(.storeServices)

        if isWishlistEnabled {
            tabs.insert(.wishlist, at: 2)
        }

        tabCoordinator = TabCoordinator(tabs: tabs, activeTab: .home(), serviceProvider: serviceProvider)

        featureAvailabilitySubscription = serviceProvider.configurationService.featureAvailabilityPublisher
            .sink { [weak self] featureAvailability in
                guard let self else { return }

                guard
                    isWishlistEnabled != (featureAvailability[.wishlist] ?? false) ||
                    isStoreServicesEnabled != (featureAvailability[.storeServices] ?? false)
                else {
                    return
                }

                rebootApp()
            }
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

private extension AppDelegate {
    private func createLogger() -> AlicerceLogging.Logger {
        let bundleID = Bundle.main.bundleIdentifier ?? Constants.defaultBundleID
        let logger = Logger(subsystem: bundleID, category: Constants.consoleLoggerCategory)

        return Log.MultiLogger<Log.NoModule, Log.NoMetadataKey>(
            destinations: [
                // swiftlint:disable:next trailing_closure
                Log.ConsoleLogDestination(
                    formatter: Log.StringLogItemFormatter { Log.ItemFormat.string },
                    minLevel: .verbose,
                    output: { logger.log(level: $0.osLogType, "\($1, privacy: .public)") }
                )
                .eraseToAnyMetadataLogDestination(),
                FirebaseLogDestination(minLevel: .verbose).eraseToAnyMetadataLogDestination(),
            ]
        )
    }
}

private extension Log.Level {
    var osLogType: OSLogType {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .verbose,
             .debug: // swiftlint:disable:this indentation_width
            return .debug
        case .info:
            return .info
        case .warning,
             .error: // swiftlint:disable:this indentation_width
            return .error
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
