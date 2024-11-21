import Combine
import Models

public class MockConfigurationService: ConfigurationServiceProtocol {
    public var isForceAppUpdateAvailable: Bool = false
    public var forceAppUpdateInfo: AppUpdateInfo? = nil
    public var isSoftAppUpdateAvailable: Bool = false
    public var softAppUpdateInfo: AppUpdateInfo? = nil

    public var forcedFeatureAvailabilitySubject: CurrentValueSubject<[ConfigurationKey: Bool], Never> = .init([:])
    public private(set) var featureAvailabilityPublisher: AnyPublisher<[ConfigurationKey: Bool], Never>

    public var forcedProviderBecameAvailableSubject: PassthroughSubject<Void, Never> = .init()
    public private(set) var providerBecameAvailablePublisher: AnyPublisher<Void, Never>

    public init(forceAppUpdateInfo: AppUpdateInfo? = nil,
                softAppUpdateInfo: AppUpdateInfo? = nil) {
        self.forceAppUpdateInfo = forceAppUpdateInfo
        self.isForceAppUpdateAvailable = forceAppUpdateInfo != nil
        self.softAppUpdateInfo = softAppUpdateInfo
        self.isSoftAppUpdateAvailable = softAppUpdateInfo != nil
        featureAvailabilityPublisher = forcedFeatureAvailabilitySubject.eraseToAnyPublisher()
        providerBecameAvailablePublisher = forcedProviderBecameAvailableSubject.eraseToAnyPublisher()
    }

    public var onIsFeatureEnabledCalled: ((ConfigurationKey) -> Bool)?
    public func isFeatureEnabled(_ key: ConfigurationKey) -> Bool {
        onIsFeatureEnabledCalled?(key) ?? false
    }

	public var onUpdateFeatureCalled: ((Bool) -> Void)?
	public func updateFeature(_ key: Models.ConfigurationKey, isEnabled: Bool) {
		onUpdateFeatureCalled?(isEnabled)
	}
}
