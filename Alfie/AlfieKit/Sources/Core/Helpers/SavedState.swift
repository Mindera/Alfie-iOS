import EasyStash
import Foundation
import Nuke

public enum SavedState {
    public static func clear(bundle: Bundle = .main, fileManager: FileManager = .default) {
        if let bundleIdentifier = bundle.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            clearRemoteConfigCache(bundleIdentifier: bundleIdentifier, fileManager: fileManager)
        }
        try? Storage(options: .init()).removeAll()
        ImagePipeline.shared.cache.removeAll()
        DataLoader.sharedUrlCache.removeAllCachedResponses()
    }

    private static func clearRemoteConfigCache(bundleIdentifier: String, fileManager: FileManager) {
        let suiteName = "group.\(bundleIdentifier).firebase"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        if let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? fileManager.removeItem(at: applicationSupport.appendingPathComponent("Google/RemoteConfig"))
        }
    }
}
