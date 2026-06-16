import XCTest
@testable import Model

final class AppGroupUserDefaultsTests: XCTestCase {
    private var suiteName: String!
    private var sut: AppGroupUserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "AppGroupUserDefaultsTests.\(UUID().uuidString)"
        sut = AppGroupUserDefaults(suiteName: suiteName)
    }

    override func tearDownWithError() throws {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        sut = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func test_set_and_value_roundtrip() {
        sut.set("hello", for: "key_string")
        let result: String? = sut.value(for: "key_string")
        XCTAssertEqual(result, "hello")
    }

    func test_returns_nil_for_missing_key() {
        let result: String? = sut.value(for: "nonexistent")
        XCTAssertNil(result)
    }

    func test_remove_clears_value() {
        sut.set(42, for: "key_int")
        sut.remove(for: "key_int")
        let result: Int? = sut.value(for: "key_int")
        XCTAssertNil(result)
    }
}
