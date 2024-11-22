import Combine
import Foundation

public protocol ConfigurationServiceProtocol {
    var featureAvailabilityPublisher: AnyPublisher<[ConfigurationKey: Bool], Never> { get }
    var providerBecameAvailablePublisher: AnyPublisher<Void, Never> { get }
    var isForceAppUpdateAvailable: Bool { get }
    var forceAppUpdateInfo: AppUpdateInfo? { get }
    var isSoftAppUpdateAvailable: Bool { get }
    var softAppUpdateInfo: AppUpdateInfo? { get }

    func isFeatureEnabled(_ key: ConfigurationKey) -> Bool
}
