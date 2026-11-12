import EasyStash
import Foundation
import Nuke

public enum SavedState {
    public static func clear() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            FirebaseRemoteConfigurationProvider.clearCache(bundleIdentifier: bundleIdentifier)
        }
        try? Storage(options: .init()).removeAll()
        ImagePipeline.shared.cache.removeAll()
        DataLoader.sharedUrlCache.removeAllCachedResponses()
    }
}
