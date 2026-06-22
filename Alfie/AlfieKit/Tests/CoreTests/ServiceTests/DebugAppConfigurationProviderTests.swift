import Combine
import XCTest
@testable import Core
import Model

final class DebugAppConfigurationProviderTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "DebugAppConfigurationProviderTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        subscriptions = []
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        subscriptions = nil
        try super.tearDownWithError()
    }

    func test_returns_nil_when_key_missing() {
        let provider = DebugAppConfigurationProvider(sharedDefaults: userDefaults)

        XCTAssertNil(provider.bool(for: .custom("missing_bool")))
        XCTAssertNil(provider.int(for: .custom("missing_int")))
        XCTAssertNil(provider.double(for: .custom("missing_double")))
        XCTAssertNil(provider.string(for: .custom("missing_string")))
        XCTAssertNil(provider.data(for: .custom("missing_data")))
    }

    func test_reads_values_from_shared_defaults() {
        let boolKey = ConfigurationKey.custom("bool_key")
        let intKey = ConfigurationKey.custom("int_key")
        let doubleKey = ConfigurationKey.custom("double_key")
        let stringKey = ConfigurationKey.custom("string_key")
        let dataKey = ConfigurationKey.custom("data_key")
        let dataValue = Data([0x01, 0x02, 0x03])

        userDefaults.set(true, forKey: boolKey.rawValue)
        userDefaults.set(42, forKey: intKey.rawValue)
        userDefaults.set(3.14, forKey: doubleKey.rawValue)
        userDefaults.set("value", forKey: stringKey.rawValue)
        userDefaults.set(dataValue, forKey: dataKey.rawValue)

        let provider = DebugAppConfigurationProvider(sharedDefaults: userDefaults)

        XCTAssertEqual(provider.bool(for: boolKey), true)
        XCTAssertEqual(provider.int(for: intKey), 42)

        if let doubleValue = provider.double(for: doubleKey) {
            XCTAssertEqual(doubleValue, 3.14, accuracy: 0.0001)
        } else {
            XCTFail("Expected double value for key \(doubleKey.rawValue)")
        }

        XCTAssertEqual(provider.string(for: stringKey), "value")
        XCTAssertEqual(provider.data(for: dataKey), dataValue)
    }

    func test_is_ready_publisher_emits_true() {
        let provider = DebugAppConfigurationProvider(sharedDefaults: userDefaults)
        let expectation = expectation(description: "isReadyPublisher emits")

        provider.isReadyPublisher
            .sink { isReady in
                XCTAssertTrue(isReady)
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: .default)
    }
}
