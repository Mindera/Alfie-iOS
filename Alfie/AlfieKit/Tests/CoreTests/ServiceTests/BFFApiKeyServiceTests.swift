@testable import Core
import Mocks
import Model
import XCTest

final class BFFApiKeyServiceTests: XCTestCase {
    private var userDefaults: MockUserDefaults!
    private var sut: BFFApiKeyService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults = MockUserDefaults()
        userDefaults.onSetCalled = { [unowned self] value, key in userDefaults.forcedValueForKey[key] = value }
        userDefaults.onRemoveCalled = { [unowned self] key in userDefaults.forcedValueForKey[key] = nil }
        sut = BFFApiKeyService(userDefaults: userDefaults, storageKey: "key")
    }

    override func tearDownWithError() throws {
        sut = nil
        userDefaults = nil
        try super.tearDownWithError()
    }

    func test_current_api_key_with_nothing_stored_is_nil() {
        XCTAssertNil(sut.currentApiKey)
    }

    func test_update_api_key_round_trips() {
        sut.updateApiKey("abc-123")

        XCTAssertEqual(sut.currentApiKey, "abc-123")
    }

    /// A key pasted from a password manager or a chat message routinely arrives with a trailing
    /// newline, which the BFF would compare literally and reject.
    func test_update_api_key_trims_surrounding_whitespace() {
        sut.updateApiKey("  abc-123\n")

        XCTAssertEqual(sut.currentApiKey, "abc-123")
    }

    func test_update_api_key_with_blank_clears_the_stored_key() {
        sut.updateApiKey("abc-123")

        sut.updateApiKey("   ")

        XCTAssertNil(sut.currentApiKey)
    }

    func test_update_api_key_with_nil_clears_the_stored_key() {
        sut.updateApiKey("abc-123")

        sut.updateApiKey(nil)

        XCTAssertNil(sut.currentApiKey)
    }

    /// Guards the read side rather than the write side: a key stored blank by an earlier build must
    /// still read as absent, so no `Bearer ` header goes out with an empty credential.
    func test_current_api_key_with_a_blank_value_already_stored_is_nil() {
        userDefaults.forcedValueForKey["key"] = "  "

        XCTAssertNil(sut.currentApiKey)
    }
}
