import AlicerceLogging
import FirebaseCore
import FirebaseCrashlytics
import Foundation

public enum CoreBootstrap {
    public static func bootstrapFirebaseApp(log: Logger) {
        log.debug("Configuring Firebase...")
        if FirebaseApp.allApps?.isEmpty ?? true {
            FirebaseApp.configure()
            FirebaseConfiguration.shared.setLoggerLevel(.warning)
            if let configuredBundleId = FirebaseApp.app()?.options.bundleID {
                log.debug("Firebase configured for bundle ID: \(configuredBundleId)")
            }
        }
    }
}
