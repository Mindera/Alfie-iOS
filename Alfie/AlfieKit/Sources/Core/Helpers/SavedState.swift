import EasyStash
import Foundation
import Nuke

public enum SavedState {
    public static func clear() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            clearRemoteConfigCache(bundleIdentifier: bundleIdentifier)
        }
        try? Storage(options: .init()).removeAll()
        ImagePipeline.shared.cache.removeAll()
        DataLoader.sharedUrlCache.removeAllCachedResponses()
    }

    private static func clearRemoteConfigCache(bundleIdentifier: String) {
        let suiteName = "group.\(bundleIdentifier).firebase"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        let fileManager = FileManager.default
        if let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? fileManager.removeItem(at: applicationSupport.appendingPathComponent("Google/RemoteConfig"))
        }
    }
}
