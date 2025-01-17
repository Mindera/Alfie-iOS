import Common
import FirebaseCore
import FirebaseCrashlytics
import Foundation

struct FirebaseLogger: LoggerProtocol {
    public func log(_ log: Log) {
        guard FirebaseApp.allApps != nil else {
            // Firebase isn't ready yet, ignore
            return
        }

        Crashlytics.crashlytics().log(log.description)
    }
}
