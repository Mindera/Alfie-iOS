import Combine
import Common
import FirebaseRemoteConfig
import Foundation
import Models

public final class FirebaseRemoteConfigurationProvider: ConfigurationProviderProtocol {
    private let remoteConfig: RemoteConfig
    private let remoteConfigSettings: RemoteConfigSettings
    private let isReadySubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var isReady: Bool { isReadySubject.value }
    public var isReadyPublisher: AnyPublisher<Bool, Never> { isReadySubject.eraseToAnyPublisher() }

    public init(
        remoteConfig: RemoteConfig = RemoteConfig.remoteConfig(),
        remoteConfigSettings: RemoteConfigSettings = RemoteConfigSettings(),
        minimumFetchInterval: TimeInterval
    ) {
        self.remoteConfig = remoteConfig
        self.remoteConfigSettings = remoteConfigSettings
        self.remoteConfigSettings.minimumFetchInterval = minimumFetchInterval

        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.fetchAndActivate { [weak self] _, error in
            if let error {
                logError("Firebase remote configuration fetch and activate failed with error: \(error.localizedDescription)")
            } else {
                self?.isReadySubject.value = true
            }
        }
    }

    // MARK: - ConfigurationProviderProtocol

    public func bool(for key: ConfigurationKey) -> Bool? {
        let configValue = remoteConfig.configValue(forKey: key.rawValue)
        guard configValue.source == .remote else {
            return nil
        }
        return configValue.boolValue
    }

    public func data(for key: ConfigurationKey) -> Data? {
        let configValue = remoteConfig.configValue(forKey: key.rawValue)
        guard configValue.source == .remote else {
            return nil
        }
        return configValue.dataValue
    }

    public func double(for key: ConfigurationKey) -> Double? {
        let configValue = remoteConfig.configValue(forKey: key.rawValue)
        guard configValue.source == .remote else {
            return nil
        }
        return configValue.numberValue as? Double
    }

    public func int(for key: ConfigurationKey) -> Int? {
        let configValue = remoteConfig.configValue(forKey: key.rawValue)
        guard configValue.source == .remote else {
            return nil
        }
        return configValue.numberValue as? Int
    }

    public func string(for key: ConfigurationKey) -> String? {
        let configValue = remoteConfig.configValue(forKey: key.rawValue)
        guard configValue.source == .remote else {
            return nil
        }
        return configValue.stringValue
    }
}
