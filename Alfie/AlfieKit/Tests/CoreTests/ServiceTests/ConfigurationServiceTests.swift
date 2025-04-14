import Combine
import TestUtils
import XCTest
@testable import Core
import Mocks
import Model

final class ConfigurationServiceTests: XCTestCase {
    private var sut: ConfigurationService!
    private var mockAuthenticationService: MockAuthenticationService!
    private var defaultCountry: String!
    private var customKey: ConfigurationKey!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthenticationService = MockAuthenticationService()
        defaultCountry = "AU"
        customKey = ConfigurationKey.custom("some_feature")
        subscriptions = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockAuthenticationService = nil
        subscriptions = nil
        try super.tearDownWithError()
    }

    // MARK: - Feature availability publisher

    func test_publishes_current_feature_availability_on_init() {
        let expectation = expectation(description: "wait for publisher")
        createService(providers: [])

        sut.featureAvailabilityPublisher
            .sink(receiveValue: { featureAvailability in
                for key in ConfigurationKey.allCases {
                    XCTAssertEqual(key.defaultAvailabilityValue, featureAvailability[key])
                }
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: .default)
    }

    func test_publishes_updated_feature_availability_after_dependency_updates() {
        let alternativeCountry = "PT"
        mockAuthenticationService.isUserSignedIn = true
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(registeredAvailable: true, registeredCountries: [alternativeCountry]),
            ])
        }

        // First sut is created with default country, features are inactive for it
        createService(providers: [provider])

        let result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)

        let expectation = expectation(description: "wait for publisher")
        sut.updateDependencies(authenticationService: mockAuthenticationService, country: alternativeCountry)

        sut.featureAvailabilityPublisher
            .sink(receiveValue: { featureAvailability in
                XCTAssertEqual(featureAvailability[ConfigurationKey.wishlist], true)
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: .default)
    }

    func test_publishes_updated_feature_availability_when_providers_become_ready() {
        let provider = MockConfigurationProvider()
        provider.isReadySubject.value = false
        provider.onBoolCalled = { _ in
            false
        }

        // First sut is created with provider not ready, wishlist feature will be active (the default)
        createService(providers: [provider])
        let result = sut.isFeatureEnabled(.wishlist)
        XCTAssertTrue(result)

        let expectation = expectation(description: "wait for publisher")
        expectation.expectedFulfillmentCount = 2

        sut.providerBecameAvailablePublisher
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        provider.isReadySubject.value = true

        sut.featureAvailabilityPublisher
            .sink(receiveValue: { featureAvailability in
                XCTAssertEqual(featureAvailability[ConfigurationKey.wishlist], false)
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: .default)
    }

    // MARK: - Test provider interaction

    func test_returns_default_value_for_key_when_no_providers_are_available() {
        createService(providers: [])
        let result = sut.isFeatureEnabled(customKey)
        XCTAssertEqual(result, customKey.defaultAvailabilityValue)
    }

    func test_returns_default_value_for_key_when_no_providers_are_ready() {
        let provider = MockConfigurationProvider()
        provider.isReadySubject.value = false
        provider.onBoolCalled = { _ in
            false
        }

        createService(providers: [provider])
        let result = sut.isFeatureEnabled(.wishlist)
        XCTAssertTrue(result) // True is the default value for this wishlist key, even though the provider says false
        XCTAssertNil(sut.softAppUpdateInfo)
        XCTAssertFalse(sut.isSoftAppUpdateAvailable)
        XCTAssertNil(sut.forceAppUpdateInfo)
        XCTAssertFalse(sut.isForceAppUpdateAvailable)
    }

    func test_gets_provider_data_value_when_checking_custom_key() {
        let provider = MockConfigurationProvider()
        let expectation = expectation(description: "wait for provider call")
        provider.onDataCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation.fulfill()
            }
            return Data()
        }

        createService(providers: [provider])
        _ = sut.isFeatureEnabled(customKey)
        wait(for: [expectation])
    }

    func test_gets_provider_data_value_when_checking_app_update() {
        let provider = MockConfigurationProvider()
        let expectation = expectation(description: "wait for provider call")
        expectation.expectedFulfillmentCount = 2
        createService(providers: [provider])

        sut.featureAvailabilityPublisher
            .sink(receiveValue: { featureAvailability in
                provider.onDataCalled = { keyParam in
                    if keyParam == .appUpdate {
                        expectation.fulfill()
                    }
                    return Data()
                }

                _ = self.sut.softAppUpdateInfo
                _ = self.sut.forceAppUpdateInfo

            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: .default)
    }

    func test_gets_provider_bool_value_when_checking_custom_key() {
        let provider = MockConfigurationProvider()
        let expectation = expectation(description: "wait for provider call")
        provider.onBoolCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation.fulfill()
            }
            return false
        }

        createService(providers: [provider])
        _ = sut.isFeatureEnabled(customKey)
        wait(for: [expectation])
    }

    func test_calls_all_available_providers_when_checking_custom_key() {
        let provider1 = MockConfigurationProvider()
        let provider2 = MockConfigurationProvider()
        let expectation = expectation(description: "wait for provider call")
        expectation.expectedFulfillmentCount = 2
        provider1.onBoolCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation.fulfill()
            }
            return nil
        }
        provider2.onBoolCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation.fulfill()
            }
            return nil
        }

        createService(providers: [provider1, provider2])
        _ = sut.isFeatureEnabled(customKey)
        wait(for: [expectation], timeout: .default)
    }

    func test_uses_first_valid_provider_value_when_checking_custom_key() {
        let provider1 = MockConfigurationProvider()
        let expectation1 = expectation(description: "wait for first provider call")
        provider1.onBoolCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation1.fulfill()
            }
            return true
        }

        let provider2 = MockConfigurationProvider()
        let expectation2 = expectation(description: "wait for second provider call")
        expectation2.isInverted = true
        provider2.onBoolCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation2.fulfill()
            }
            return nil
        }

        createService(providers: [provider1, provider2])
        let result = sut.isFeatureEnabled(customKey)
        wait(for: [expectation1, expectation2], timeout: .inverted)
        XCTAssertTrue(result)
    }

    func test_returns_default_value_for_key_when_no_provider_has_value_for_custom_key() {
        let provider = MockConfigurationProvider()
        createService(providers: [provider])
        let result = sut.isFeatureEnabled(customKey)
        XCTAssertEqual(result, customKey.defaultAvailabilityValue)
    }

    func test_returns_default_value_for_key_when_no_provider_has_valid_value_for_custom_key() {
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return Data()
        }
        createService(providers: [provider])
        var result = sut.isFeatureEnabled(customKey)
        XCTAssertEqual(result, customKey.defaultAvailabilityValue)

        for key in ConfigurationKey.allCases {
            result = sut.isFeatureEnabled(key)
            XCTAssertEqual(result, key.defaultAvailabilityValue)
        }
    }

    // MARK: - Test feature availability (boolean)

    func test_checks_availability_of_feature_configured_with_bool() {
        let provider = MockConfigurationProvider()
        provider.onBoolCalled = { _ in
            return true
        }

        createService(providers: [provider])
        var result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)

        provider.onBoolCalled = { _ in
            return false
        }

        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)
    }

    // MARK: - Test App Update availability

    func test_checks_appUpdate_by_versions() {
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { keyParam in
            if keyParam == .appUpdate {
                let softUpdate = ConfigurationAppUpdateInfo.fixture(minimumAppVersion: .init("0.1.1"))
                let forceUpdate = ConfigurationAppUpdateInfo.fixture(minimumAppVersion: .init("0.1.0"))
                return self.appUpdateData(configuration: .fixture(requirements: .fixture(immediate: forceUpdate, flexible: softUpdate)))
            }
            return nil
        }

        // Above version - no update available but still have the info
        createService(providers: [provider], version: "0.1.2")
        XCTAssertFalse(sut.isSoftAppUpdateAvailable)
        XCTAssertNotNil(sut.softAppUpdateInfo)
        XCTAssertFalse(sut.isForceAppUpdateAvailable)
        XCTAssertNotNil(sut.forceAppUpdateInfo)
        // Same version - no update available but still have the info
        createService(providers: [provider], version: "0.1.1")
        XCTAssertFalse(sut.isSoftAppUpdateAvailable)
        XCTAssertNotNil(sut.softAppUpdateInfo)
        XCTAssertFalse(sut.isForceAppUpdateAvailable)
        XCTAssertNotNil(sut.forceAppUpdateInfo)
        // Below flexible version - soft update
        createService(providers: [provider], version: "0.1.0")
        XCTAssertTrue(sut.isSoftAppUpdateAvailable)
        XCTAssertFalse(sut.isForceAppUpdateAvailable)
        // Below immediate version - force update
        createService(providers: [provider], version: "0.0.9")
        XCTAssertTrue(sut.isSoftAppUpdateAvailable)
        XCTAssertTrue(sut.isForceAppUpdateAvailable)
    }

    func test_checks_appUpdate_by_versions_when_provider_become_ready() {
        let provider = MockConfigurationProvider()
        provider.isReadySubject.value = false
        
        createService(providers: [provider], version: "0.1.0")
        let expectation = expectation(description: "wait for provider to become available")

        provider.onDataCalled = { keyParam in
            if keyParam == .appUpdate {
                let softUpdate = ConfigurationAppUpdateInfo.fixture(minimumAppVersion: .init("0.3.0"))
                let forceUpdate = ConfigurationAppUpdateInfo.fixture(minimumAppVersion: .init("0.2.0"))
                return self.appUpdateData(configuration: .fixture(
                    requirements: .fixture(immediate: forceUpdate, flexible: softUpdate)
                ))
            }
            return nil
        }

        sut.providerBecameAvailablePublisher
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        // No data from provider - no update
        XCTAssertNil(sut.softAppUpdateInfo)
        XCTAssertFalse(sut.isSoftAppUpdateAvailable)
        XCTAssertNil(sut.forceAppUpdateInfo)
        XCTAssertFalse(sut.isForceAppUpdateAvailable)

        provider.isReadySubject.value = true

        wait(for: [expectation], timeout: .default)

        // force and soft update available
        XCTAssertNotNil(sut.softAppUpdateInfo)
        XCTAssertTrue(sut.isSoftAppUpdateAvailable)
        XCTAssertNotNil(sut.forceAppUpdateInfo)
        XCTAssertTrue(sut.isForceAppUpdateAvailable)
    }

    // MARK: - Test feature availability (version)

    func test_checks_availability_of_disabled_feature() {
        let provider = MockConfigurationProvider()
        let expectation = expectation(description: "wait for provider call")
        provider.onDataCalled = { keyParam in
            if keyParam.rawValue == self.customKey.rawValue {
                expectation.fulfill()
            }
            return self.versionsFixtureData([self.versionFixture()])
        }

        createService(providers: [provider])
        let result = sut.isFeatureEnabled(customKey)
        wait(for: [expectation], timeout: .default)
        XCTAssertFalse(result)
    }

    func test_checks_availability_of_feature_by_version() {
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(version: "1.2.0", registeredAvailable: true, guestAvailable: true),
                self.versionFixture(version: "2.0.0", registeredAvailable: false, guestAvailable: false)
            ])
        }

        createService(providers: [provider], version: "1.3.0")
        var result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)

        createService(providers: [provider], version: "2.3.0")
        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)
    }

    func test_checks_availability_of_feature_by_user_type() {
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(registeredAvailable: true, guestAvailable: false),
            ])
        }

        createService(providers: [provider])
        mockAuthenticationService.isUserSignedIn = true
        var result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)

        mockAuthenticationService.isUserSignedIn = false
        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)

        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(registeredAvailable: false, guestAvailable: true),
            ])
        }

        mockAuthenticationService.isUserSignedIn = true
        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)
        mockAuthenticationService.isUserSignedIn = false
        result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)
    }

    func test_checks_availability_of_feature_by_country() {
        mockAuthenticationService.isUserSignedIn = true
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(registeredAvailable: true, registeredCountries: [self.defaultCountry]),
            ])
        }

        // First sut is created with default country, feature is active for it
        createService(providers: [provider])

        var result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)

        // Second sut is created with different country, feature is inactive for it
        createService(providers: [provider], country: "PT")
        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)
    }

    func test_checks_availability_of_feature_by_release_type_testflight() {
        mockAuthenticationService.isUserSignedIn = true
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(registeredAvailable: true, registeredReleaseTypes: ["testflight"]),
            ])
        }

        // First sut is created as a TestFlight app, feature is active for it
        createService(providers: [provider], isStoreApp: false)

        var result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)

        // Second sut is created as a Store app, feature is inactive for it
        createService(providers: [provider], isStoreApp: true)
        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)
    }

    func test_checks_availability_of_feature_by_release_type_store() {
        mockAuthenticationService.isUserSignedIn = true
        let provider = MockConfigurationProvider()
        provider.onDataCalled = { _ in
            return self.versionsFixtureData([
                self.versionFixture(registeredAvailable: true, registeredReleaseTypes: ["store"]),
            ])
        }

        // First sut is created as a Store app, feature is active for it
        createService(providers: [provider], isStoreApp: true)

        var result = sut.isFeatureEnabled(customKey)
        XCTAssertTrue(result)

        // Second sut is created as a TestFlight app, feature is inactive for it
        createService(providers: [provider], isStoreApp: false)
        result = sut.isFeatureEnabled(customKey)
        XCTAssertFalse(result)
    }
}

extension ConfigurationServiceTests {
    // MARK: - Private utils

    private func createService(providers: [ConfigurationProviderProtocol],
                               country: String? = nil,
                               isStoreApp: Bool = false,
                               version: String = "0") {
        sut = ConfigurationService(providers: providers,
                                   authenticationService: mockAuthenticationService,
                                   country: country ?? defaultCountry,
                                   appVersion: version,
                                   isStoreApp: isStoreApp)
    }

    private func versionFixture(version: String = "0",
                                registeredAvailable: Bool = false,
                                registeredCountries: [String] = [],
                                registeredReleaseTypes: [String] = [],
                                guestAvailable: Bool = false,
                                guestCountries: [String] = [],
                                guestReleaseTypes: [String] = []) -> ConfigurationVersion {

        let registeredConfig = ConfigurationUserConfig(available: registeredAvailable,
                                                       countryCodes: registeredCountries,
                                                       releaseTypes: registeredReleaseTypes)
        let guestConfig = ConfigurationUserConfig(available: guestAvailable,
                                                  countryCodes: guestCountries,
                                                  releaseTypes: guestReleaseTypes)
        return ConfigurationVersion(minimumAppVersion: Version(version),
                                    registeredUsersConfig: registeredConfig,
                                    guestUsersConfig: guestConfig)

    }

    private func versionsFixtureData(_ versions: [ConfigurationVersion]) -> Data? {
        return try? JSONEncoder().encode(["versions": versions])
    }

    private func appUpdateData(configuration: ConfigurationAppUpdate) -> Data? {
        try? JSONEncoder().encode(configuration)
    }
}
