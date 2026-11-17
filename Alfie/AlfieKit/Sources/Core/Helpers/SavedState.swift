import EasyStash
import Foundation
import Nuke

public enum SavedState {
    public static func clear(preservingDefaults preservedKeys: Set<String> = []) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let defaults = UserDefaults.standard
            let preserved = defaults.persistentDomain(forName: bundleIdentifier)?
                .filter { preservedKeys.contains($0.key) } ?? [:]
            defaults.setPersistentDomain(preserved, forName: bundleIdentifier)
            FirebaseRemoteConfigurationProvider.clearCache(bundleIdentifier: bundleIdentifier)
        }
        try? Storage(options: .init()).removeAll()
        ImagePipeline.shared.cache.removeAll()
        DataLoader.sharedUrlCache.removeAllCachedResponses()
    }
}
