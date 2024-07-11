import Combine
import Foundation
import Models

public final class LocalConfigurationProvider: ConfigurationProviderProtocol {
    private var localConfig: [String: Any]?
    private let isReadySubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isReady: Bool { isReadySubject.value }
    public var isReadyPublisher: AnyPublisher<Bool, Never> { isReadySubject.eraseToAnyPublisher() }

    public init() {
        loadConfig()
    }

    // MARK: - ConfigurationProviderProtocol

    public func bool(for key: ConfigurationKey) -> Bool? {
        guard let localConfig, localConfig.has(key: key.rawValue) else {
            return nil
        }
        return localConfig[key.rawValue] as? Bool
    }

    public func data(for key: ConfigurationKey) -> Data? {
        guard let localConfig, localConfig.has(key: key.rawValue), let value = localConfig[key.rawValue] as? [String: [Any]] else {
            return nil
        }

        return try? JSONSerialization.data(withJSONObject: value)
    }

    public func double(for key: ConfigurationKey) -> Double? {
        guard let localConfig, localConfig.has(key: key.rawValue) else {
            return nil
        }
        return localConfig[key.rawValue] as? Double
    }

    public func int(for key: ConfigurationKey) -> Int? {
        guard let localConfig, localConfig.has(key: key.rawValue) else {
            return nil
        }
        return localConfig[key.rawValue] as? Int
    }

    public func string(for key: ConfigurationKey) -> String? {
        guard let localConfig, localConfig.has(key: key.rawValue) else {
            return nil
        }
        return localConfig[key.rawValue] as? String
    }

    // MARK: - Private

    private func loadConfig() {
        guard let path = Bundle.main.path(forResource: "local_config", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
            return
        }

        localConfig = object
        isReadySubject.value = true
    }
}
