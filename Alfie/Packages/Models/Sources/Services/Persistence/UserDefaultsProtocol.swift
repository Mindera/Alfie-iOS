import Foundation

public protocol UserDefaultsProtocol {
    func set<T>(_ value: T, for key: String)
    func value<T>(for key: String) -> T?
    func remove(for key: String)
}

extension UserDefaults: UserDefaultsProtocol {
    public func set<T>(_ value: T, for key: String) {
        set(value, forKey: key)
    }

    public func value<T>(for key: String) -> T? {
        guard let object = object(forKey: key) as? T else {
            return nil
        }

        return object
    }

    public func remove(for key: String) {
        removeObject(forKey: key)
    }
}
