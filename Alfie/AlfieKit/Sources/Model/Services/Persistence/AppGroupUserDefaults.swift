import Foundation

public final class AppGroupUserDefaults: UserDefaultsProtocol {
    private let userDefaults: UserDefaults

    public init(suiteName: String) {
        self.userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func set<T>(_ value: T, for key: String) {
        userDefaults.set(value, forKey: key)
    }

    public func value<T>(for key: String) -> T? {
        userDefaults.object(forKey: key) as? T
    }

    public func remove(for key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
