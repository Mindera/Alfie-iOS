import Foundation
import Model
import Utils

/// The key belongs to the Custom endpoint: sending it to any other endpoint would hand a staging
/// key to a host it was never meant for.
public final class BFFApiKeyService: BFFApiKeyServiceProtocol {
    public static let defaultStorageKey = "com.alfie.config.bff.apiKey"

    private let userDefaults: UserDefaultsProtocol
    private let apiEndpointService: ApiEndpointServiceProtocol
    private let storageKey: String

    public init(
        userDefaults: UserDefaultsProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        storageKey: String = BFFApiKeyService.defaultStorageKey
    ) {
        self.userDefaults = userDefaults
        self.apiEndpointService = apiEndpointService
        self.storageKey = storageKey
    }

    public var currentApiKey: String? {
        guard apiEndpointService.currentApiEndpoint.customUrl != nil else {
            return nil
        }

        return storedApiKey
    }

    public var storedApiKey: String? {
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
