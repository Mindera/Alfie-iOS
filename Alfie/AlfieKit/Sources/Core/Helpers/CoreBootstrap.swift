import Common
import FirebaseCore
import FirebaseCrashlytics
import Foundation

public enum CoreBootstrap {
    public static func bootstrap() {
        // Setup loggers: default system console and Firebase Crashlytics
        // but don't add the system logger when running App Store release builds
        var loggers = [LoggerProtocol]()
        if !ReleaseConfigurator.isRelease {
            loggers.append(DefaultSystemLogger())
        }
        loggers.append(FirebaseLogger())
        logManager.setLoggers(loggers)

        // Bootstrap dependencies
        bootstrapFirebaseApp()
    }

    private static func bootstrapFirebaseApp() {
        log("Configuring Firebase...")
        if FirebaseApp.allApps?.isEmpty ?? true {
            FirebaseApp.configure()
            FirebaseConfiguration.shared.setLoggerLevel(.warning)
            if let configuredBundleId = FirebaseApp.app()?.options.bundleID {
                log("Firebase configured for bundle ID: \(configuredBundleId)", printToConsole: false)
            }
        }
    }
}
