import Foundation
import Model
import Utils

/// The BFF rejects every request without a `Bearer` credential, so the key has to reach the device
/// somehow. Keeping it in `UserDefaults` and typing it into the debug menu keeps it out of the
/// repository — a checked-in default would be a committed secret, whatever the environment.
public final class BFFApiKeyService: BFFApiKeyServiceProtocol {
    public static let defaultStorageKey = "com.alfie.config.bff.apiKey"

    private let userDefaults: UserDefaultsProtocol
    private let storageKey: String

    public init(userDefaults: UserDefaultsProtocol, storageKey: String = BFFApiKeyService.defaultStorageKey) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public var currentApiKey: String? {
        let stored: String? = userDefaults.value(for: storageKey)
        guard let stored, stored.isNotBlank else {
            return nil
        }

        return stored.trim()
    }

    public func updateApiKey(_ apiKey: String?) {
        guard let apiKey, apiKey.isNotBlank else {
            userDefaults.remove(for: storageKey)
            return
        }

        userDefaults.set(apiKey.trim(), for: storageKey)
    }
}
