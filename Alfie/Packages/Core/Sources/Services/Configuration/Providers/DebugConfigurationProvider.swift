import Combine
import Foundation
import Models

public final class DebugConfigurationProvider: DebugConfigurationProviderProtocol {
    private static let userDefaultsKey = "featureToggles"
    private static let debugConfigurationKey = "debugConfigurationOverride"

    public static var shared: DebugConfigurationProviderProtocol = DebugConfigurationProvider()

    private var localConfig: [String: Data] = [:]
    private let isReadySubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isReady: Bool { isReadySubject.value }
    public var isReadyPublisher: AnyPublisher<Bool, Never> { isReadySubject.eraseToAnyPublisher() }

    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()

    private init() {
        loadConfig()
    }

    // MARK: - ConfigurationProviderProtocol
    public func toggleAvailability() {
        let newState = !isReady

        UserDefaults.standard.set(newState, for: Self.debugConfigurationKey)

        isReadySubject.value = newState
    }

    public func bool(for key: ConfigurationKey) -> Bool? {
        guard localConfig.has(key: key.rawValue), let data = localConfig[key.rawValue] else {
            return nil
        }

        return try? decoder.decode(Bool.self, from: data)
    }

    public func data(for key: ConfigurationKey) -> Data? {
        guard localConfig.has(key: key.rawValue), let data = localConfig[key.rawValue] else {
            return nil
        }

        return data
    }

    public func double(for key: ConfigurationKey) -> Double? {
        guard localConfig.has(key: key.rawValue), let data = localConfig[key.rawValue] else {
            return nil
        }

        return try? decoder.decode(Double.self, from: data)
    }

    public func int(for key: ConfigurationKey) -> Int? {
        guard localConfig.has(key: key.rawValue), let data = localConfig[key.rawValue] else {
            return nil
        }

        return try? decoder.decode(Int.self, from: data)
    }

    public func string(for key: ConfigurationKey) -> String? {
        guard localConfig.has(key: key.rawValue), let data = localConfig[key.rawValue] else {
            return nil
        }

        return try? decoder.decode(String.self, from: data)
    }

    public func updateFeature(_ key: ConfigurationKey, isEnabled: Bool) {
        setValue(isEnabled, for: key)
    }

    // MARK: - Private

    private func loadConfig() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
            let config = try? decoder.decode([String: Data].self, from: data)
        else {
            return
        }

        self.isReadySubject.value = UserDefaults.standard.bool(forKey: Self.debugConfigurationKey)
        self.localConfig = config
    }

    private func syncLocalConfig() {
        guard let data = try? encoder.encode(localConfig) else {
            return
        }

        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
    }

    private func setValue<T: Encodable>(_ value: T, for key: ConfigurationKey) {
        guard let data = try? encoder.encode(value) else {
            return
        }

        localConfig[key.rawValue] = data
        syncLocalConfig()
    }
}