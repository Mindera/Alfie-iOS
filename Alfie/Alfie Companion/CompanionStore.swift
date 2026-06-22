import Foundation
import Model
import Combine

private let appGroupSuiteName = "group.com.mindera.alfie.shared"
private let endpointKey = "com.alfie.config.api.endpoint"

final class CompanionStore: ObservableObject {
    @Published private(set) var flagOverrides: [String: Bool] = [:]
    @Published private(set) var endpointUrlString: String?
    @Published private(set) var allGroupEntries: [(key: String, value: String)] = []

    private let suite: UserDefaults

    init() {
        self.suite = UserDefaults(suiteName: appGroupSuiteName) ?? .standard
        reload()
    }

    // MARK: - Reload

    func reload() {
        var overrides: [String: Bool] = [:]
        for key in ConfigurationKey.allCases {
            if let val = suite.object(forKey: key.rawValue) as? Bool {
                overrides[key.rawValue] = val
            }
        }
        flagOverrides = overrides
        endpointUrlString = suite.string(forKey: endpointKey)

        let raw = suite.dictionaryRepresentation()
        allGroupEntries = raw
            .filter { !$0.key.hasPrefix("Apple") }
            .map { (key: $0.key, value: "\($0.value)") }
            .sorted { $0.key < $1.key }
    }

    // MARK: - Flags

    func setFlag(rawKey: String, value: Bool) {
        suite.set(value, forKey: rawKey)
        reload()
    }

    func removeFlag(rawKey: String) {
        suite.removeObject(forKey: rawKey)
        reload()
    }

    // MARK: - Endpoint

    func setEndpoint(urlString: String) {
        suite.set(urlString, forKey: endpointKey)
        reload()
    }

    func removeEndpoint() {
        suite.removeObject(forKey: endpointKey)
        reload()
    }

    // MARK: - App Group browser

    func removeEntry(key: String) {
        suite.removeObject(forKey: key)
        reload()
    }

    // MARK: - Reset All

    func resetAll() {
        for key in ConfigurationKey.allCases {
            suite.removeObject(forKey: key.rawValue)
        }
        suite.removeObject(forKey: endpointKey)
        reload()
    }
}
