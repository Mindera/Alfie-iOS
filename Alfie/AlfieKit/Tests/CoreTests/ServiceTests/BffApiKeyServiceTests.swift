@testable import Core
import Mocks
import Model
import XCTest

final class BffApiKeyServiceTests: XCTestCase {
    private var userDefaults: MockUserDefaults!
    private var sut: BffApiKeyService!

    override func setUp() {
        super.setUp()
        userDefaults = MockUserDefaults()
        userDefaults.onSetCalled = { [unowned self] value, key in userDefaults.forcedValueForKey[key] = value }
        userDefaults.onRemoveCalled = { [unowned self] key in userDefaults.forcedValueForKey[key] = nil }
        sut = BffApiKeyService(userDefaults: userDefaults, storageKey: "key")
    }

    override func tearDown() {
        sut = nil
        userDefaults = nil
        super.tearDown()
    }

    func test_currentApiKey_with_nothing_stored_is_nil() {
        XCTAssertNil(sut.currentApiKey)
    }

    func test_updateApiKey_round_trips() {
        sut.updateApiKey("abc-123")

        XCTAssertEqual(sut.currentApiKey, "abc-123")
    }

    /// A key pasted from a password manager or a chat message routinely arrives with a trailing
    /// newline, which the BFF would compare literally and reject.
    func test_updateApiKey_trims_surrounding_whitespace() {
        sut.updateApiKey("  abc-123\n")

        XCTAssertEqual(sut.currentApiKey, "abc-123")
    }

    func test_updateApiKey_with_blank_clears_the_stored_key() {
        sut.updateApiKey("abc-123")

        sut.updateApiKey("   ")

        XCTAssertNil(sut.currentApiKey)
    }

    func test_updateApiKey_with_nil_clears_the_stored_key() {
        sut.updateApiKey("abc-123")

        sut.updateApiKey(nil)

        XCTAssertNil(sut.currentApiKey)
    }

    /// Guards the read side rather than the write side: a key stored blank by an earlier build must
    /// still read as absent, so no `Bearer ` header goes out with an empty credential.
    func test_currentApiKey_with_a_blank_value_already_stored_is_nil() {
        userDefaults.forcedValueForKey["key"] = "  "

        XCTAssertNil(sut.currentApiKey)
    }
}
