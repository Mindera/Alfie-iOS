import Combine
import Common
import Foundation
import Model

private enum ConfigurationReleaseType: String {
    case store
    case testflight
}

private enum AppUpdateType {
    case immediate
    case flexible
}

public final class ConfigurationService: ConfigurationServiceProtocol {
    private let providers: [ConfigurationProviderProtocol]
    private let appVersion: Version
    private let isStoreApp: Bool
    // Updatable dependencies
    private var authenticationService: AuthenticationServiceProtocol?
    private var currentCountry: String

    private let featureAvailabilitySubject: CurrentValueSubject<[ConfigurationKey: Bool], Never> = .init([:])
    public private(set) var featureAvailabilityPublisher: AnyPublisher<[ConfigurationKey: Bool], Never>
    private let providerBecameAvailableSubject: PassthroughSubject<Void, Never> = .init()
    public private(set) var providerBecameAvailablePublisher: AnyPublisher<Void, Never>
    private var subscriptions = Set<AnyCancellable>()

    public init(
        providers: [ConfigurationProviderProtocol],
        authenticationService: AuthenticationServiceProtocol?,
        country: String,
        appVersion: String = Bundle.main.appVersion,
        isStoreApp: Bool = ReleaseConfigurator.appConfiguration == .appStore
    ) {
        self.providers = providers
        self.authenticationService = authenticationService
        self.currentCountry = country
        self.isStoreApp = isStoreApp
        self.appVersion = Version(appVersion)
        self.featureAvailabilityPublisher = featureAvailabilitySubject.eraseToAnyPublisher()
        self.providerBecameAvailablePublisher = providerBecameAvailableSubject.eraseToAnyPublisher()

        updateFeatureAvailability()

        Publishers.MergeMany(self.providers.map { $0.isReadyPublisher })
            .sink { [weak self] isReady in
                guard let self else { return }

                updateFeatureAvailability()

                if isReady {
                    providerBecameAvailableSubject.send()
                }
            }
            .store(in: &subscriptions)

        Publishers.MergeMany(self.providers.map { $0.configurationUpdatedPublisher })
            .sink { [weak self] in
                self?.updateFeatureAvailability()
            }
            .store(in: &subscriptions)
    }

    func updateDependencies(authenticationService: AuthenticationServiceProtocol?, country: String) {
        self.authenticationService = authenticationService
        self.currentCountry = country

        updateFeatureAvailability()
    }

    // MARK: - ConfigurationServiceProtocol

    public func isFeatureEnabled(_ key: ConfigurationKey) -> Bool {
        // Custom keys must always be read in real time, others are fetched from the publisher
        if case .custom = key {
            return checkFeatureAvailability(key: key)
        }

        // If for some reason we don't have the feature in the current value subject, read it in real time
        guard let value = featureAvailabilitySubject.value[key] else {
            return checkFeatureAvailability(key: key)
        }

        return value
    }

    // MARK: - App Update

    public var isForceAppUpdateAvailable: Bool {
        guard let forceAppUpdateInfo else {
            return false
        }
        return appVersion < forceAppUpdateInfo.minimumAppVersion
    }

    public var forceAppUpdateInfo: AppUpdateInfo? {
        appUpdateInfo(type: .immediate)
    }

    public var isSoftAppUpdateAvailable: Bool {
        guard let softAppUpdateInfo else {
            return false
        }
        return appVersion < softAppUpdateInfo.minimumAppVersion
    }

    public var softAppUpdateInfo: AppUpdateInfo? {
        appUpdateInfo(type: .flexible)
    }
}

// MARK: - Private Helper Methods

extension ConfigurationService {
    private func updateFeatureAvailability() {
        var values = [ConfigurationKey: Bool]()

        ConfigurationKey.allCases.forEach { key in
            values[key] = checkFeatureAvailability(key: key)
        }

        featureAvailabilitySubject.value = values
    }

    private func checkFeatureAvailability(key: ConfigurationKey) -> Bool {
        guard let rawValue = providerValue(for: key), let configValue = ConfigurationValue(rawValue: rawValue) else {
            return key.defaultAvailabilityValue
        }

        if let boolValue = configValue.boolValue {
            return boolValue
        } else if let versionsValue = configValue.versionsValue {
            return checkAvailability(using: versionsValue) ?? key.defaultAvailabilityValue
        } else if key == .appUpdate && configValue.appUpdate != nil {
            return false
        } else {
            assertionFailure("Unexpected empty config value")
            return key.defaultAvailabilityValue
        }
    }

    private func appUpdateInfo(type: AppUpdateType) -> AppUpdateInfo? {
        guard
            let rawValue = providerValue(for: .appUpdate),
            let appUpdate = ConfigurationValue(rawValue: rawValue)?.appUpdate,
            let configuration: ConfigurationAppUpdateInfo = switch type {
            // swiftlint:disable vertical_whitespace_between_cases
            case .immediate:
                appUpdate.requirements.immediate
            case .flexible:
                appUpdate.requirements.flexible
            // swiftlint:enable vertical_whitespace_between_cases
            } else {
                return nil
            }

        let redirectUrl = URL(string: appUpdate.url)
        return .init(configuration: configuration, url: redirectUrl)
    }

    private func providerValue(for key: ConfigurationKey) -> Any? {
        for provider in providers where provider.isReady {
            if let value = provider.data(for: key), !value.isEmpty {
                return value
            } else if let value = provider.bool(for: key) {
                return value
            }
        }

        return nil
    }

    private func checkAvailability(using versions: ConfigurationVersions) -> Bool? {
        // Can't continue without an authentication service to check if the user is guest
        guard let authenticationService else {
            return nil
        }

        let isRegistered = authenticationService.isUserSignedIn
        let orderedVersions = versions.versions.sorted { lhs, rhs in
            lhs.minimumAppVersion > rhs.minimumAppVersion
        }

        // Only check config versions for which our app version is >=
        for version in orderedVersions where appVersion >= version.minimumAppVersion {
            if isRegistered {
                // If the feature is disabled for registered users and we're registered, return false, no need to check anything else
                guard version.registeredUsersConfig.available else {
                    return false
                }

                let checkCountry = checkCountry(version.registeredUsersConfig.countryCodes)
                let checkReleaseType = checkReleaseType(version.registeredUsersConfig.releaseTypes)

                return checkCountry && checkReleaseType
            } else {
                // If the feature is disabled for guest users and we're a guest user, return false, no need to check anything else
                guard version.guestUsersConfig.available else {
                    return false
                }

                let checkCountry = checkCountry(version.guestUsersConfig.countryCodes)
                let checkReleaseType = checkReleaseType(version.guestUsersConfig.releaseTypes)

                return checkCountry && checkReleaseType
            }
        }

        // No config for this app version
        return nil
    }

    private func checkCountry(_ countries: [String]) -> Bool {
        guard !countries.isEmpty else {
            return true
        }

        return countries.contains { $0.lowercased() == currentCountry.lowercased() }
    }

    private func checkReleaseType(_ releaseTypes: [String]) -> Bool {
        guard !releaseTypes.isEmpty else {
            return true
        }

        let storeReleaseType = ConfigurationReleaseType.store.rawValue
        let testflightReleaseType = ConfigurationReleaseType.testflight.rawValue
        let expectedReleaseType = isStoreApp ? storeReleaseType : testflightReleaseType

        return releaseTypes.contains { $0.caseInsensitiveCompare(expectedReleaseType) == .orderedSame }
    }
}
