import Model

public final class MockUserDefaults: UserDefaultsProtocol {
    public var onSetCalled: ((_: Any?, _: String) -> Void)?
    public var onValueForKeyCalled: ((_: String) -> Any?)?
    public var onRemoveCalled: ((_: String) -> Void)?
    public var forcedValueForKey: [String: Any] = [:]

    private(set) var valuesAndKeysSet: [String: Any] = [:]
    private(set) var keysRemoved: [String] = []
    private(set) var keysRetrieved: [String] = []

    public init() {}

    public func set<T>(_ value: T, for key: String) {
        valuesAndKeysSet[key] = value
        onSetCalled?(value, key)
    }

    public func value<T>(for key: String) -> T? {
        keysRetrieved.append(key)

        return (onValueForKeyCalled?(key) as? T) ?? forcedValueForKey[key] as? T
    }

    public func remove(for key: String) {
        keysRemoved.append(key)
        onRemoveCalled?(key)
    }
}

