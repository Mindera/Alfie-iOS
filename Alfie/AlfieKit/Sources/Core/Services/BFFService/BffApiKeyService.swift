import Foundation
import Model

/// The BFF rejects every request without a `Bearer` credential, so the key has to reach the device
/// somehow. Keeping it in `UserDefaults` and typing it into the debug menu keeps it out of the
/// repository — a checked-in default would be a committed secret, whatever the environment.
public final class BffApiKeyService: BffApiKeyServiceProtocol {
    public static let defaultStorageKey = "com.alfie.config.bff.apiKey"

    private let userDefaults: UserDefaultsProtocol
    private let storageKey: String

    public init(userDefaults: UserDefaultsProtocol, storageKey: String = BffApiKeyService.defaultStorageKey) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public var currentApiKey: String? {
        let stored: String? = userDefaults.value(for: storageKey)
        return stored?.trimmingCharacters(in: .whitespacesAndNewlines).nilWhenEmpty
    }

    public func updateApiKey(_ apiKey: String?) {
        guard let apiKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines).nilWhenEmpty else {
            userDefaults.remove(for: storageKey)
            return
        }

        userDefaults.set(apiKey, for: storageKey)
    }
}

private extension String {
    var nilWhenEmpty: String? {
        isEmpty ? nil : self
    }
}
