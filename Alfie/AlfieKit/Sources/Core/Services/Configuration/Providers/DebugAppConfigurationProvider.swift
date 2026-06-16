import Combine
import Foundation
import Model

public final class DebugAppConfigurationProvider: ConfigurationProviderProtocol {
    public var isReady: Bool { true }
    public var isReadyPublisher: AnyPublisher<Bool, Never> { isReadySubject.eraseToAnyPublisher() }
    public var configurationUpdatedPublisher: AnyPublisher<Void, Never> {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }

    private let sharedDefaults: UserDefaults?
    private let isReadySubject = CurrentValueSubject<Bool, Never>(true)

    public init(sharedDefaults: UserDefaults? = UserDefaults(suiteName: "group.com.mindera.alfie.shared")) {
        self.sharedDefaults = sharedDefaults
    }

    // MARK: - ConfigurationProviderProtocol

    public func bool(for key: ConfigurationKey) -> Bool? {
        sharedDefaults?.object(forKey: key.rawValue) as? Bool
    }

    public func data(for key: ConfigurationKey) -> Data? {
        sharedDefaults?.object(forKey: key.rawValue) as? Data
    }

    public func double(for key: ConfigurationKey) -> Double? {
        sharedDefaults?.object(forKey: key.rawValue) as? Double
    }

    public func int(for key: ConfigurationKey) -> Int? {
        sharedDefaults?.object(forKey: key.rawValue) as? Int
    }

    public func string(for key: ConfigurationKey) -> String? {
        sharedDefaults?.object(forKey: key.rawValue) as? String
    }
}
