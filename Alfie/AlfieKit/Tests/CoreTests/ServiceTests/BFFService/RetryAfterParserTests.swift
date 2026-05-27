@testable import Core
import Foundation
import XCTest

final class RetryAfterParserTests: XCTestCase {
    func test_parses_integer_seconds() {
        XCTAssertEqual(RetryAfterParser.parse(headerValue: "10"), 10)
        XCTAssertEqual(RetryAfterParser.parse(headerValue: "0"), 0)
    }

    func test_returns_nil_for_nil_or_empty() {
        XCTAssertNil(RetryAfterParser.parse(headerValue: nil))
        XCTAssertNil(RetryAfterParser.parse(headerValue: ""))
        XCTAssertNil(RetryAfterParser.parse(headerValue: "   "))
    }

    func test_returns_nil_for_garbage() {
        XCTAssertNil(RetryAfterParser.parse(headerValue: "not-a-date"))
    }

    func test_parses_imf_fixdate() {
        let now = Date(timeIntervalSince1970: 783_000_000) // 1994-10-25
        let result = RetryAfterParser.parse(headerValue: "Sun, 06 Nov 1994 08:49:37 GMT", now: now)
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result ?? 0, 0)
    }

    func test_parses_rfc_850() {
        let now = Date(timeIntervalSince1970: 783_000_000)
        let result = RetryAfterParser.parse(headerValue: "Sunday, 06-Nov-94 08:49:37 GMT", now: now)
        XCTAssertNotNil(result)
    }

    func test_parses_asctime() {
        let now = Date(timeIntervalSince1970: 783_000_000)
        let result = RetryAfterParser.parse(headerValue: "Sun Nov  6 08:49:37 1994", now: now)
        XCTAssertNotNil(result)
    }

    func test_clamps_past_date_to_zero() {
        let now = Date(timeIntervalSince1970: 1_000_000_000) // 2001
        let result = RetryAfterParser.parse(headerValue: "Sun, 06 Nov 1994 08:49:37 GMT", now: now)
        XCTAssertEqual(result, 0)
    }
}
