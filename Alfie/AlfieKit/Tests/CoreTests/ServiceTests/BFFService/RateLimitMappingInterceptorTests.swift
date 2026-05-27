import Apollo
import ApolloAPI
import BFFGraph
@testable import Core
import Foundation
import Model
import XCTest

final class RateLimitMappingInterceptorTests: XCTestCase {
    func test_maps_429_with_integer_retry_after() {
        let chain = MockRequestChain()
        let interceptor = RateLimitMappingInterceptor()

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 429, headers: ["Retry-After": "10"]),
            completion: { _ in }
        )

        XCTAssertEqual(chain.handleErrorCount, 1)
        guard let bff = chain.capturedError as? BFFRequestError,
              case .rateLimited(let retryAfter) = bff.type else {
            XCTFail("Expected .rateLimited; got \(String(describing: chain.capturedError))")
            return
        }
        XCTAssertEqual(retryAfter, 10)
    }

    func test_maps_430_without_retry_after() {
        let chain = MockRequestChain()
        let interceptor = RateLimitMappingInterceptor()

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 430),
            completion: { _ in }
        )

        XCTAssertEqual(chain.handleErrorCount, 1)
        guard let bff = chain.capturedError as? BFFRequestError,
              case .rateLimited(let retryAfter) = bff.type else {
            XCTFail("Expected .rateLimited")
            return
        }
        XCTAssertNil(retryAfter)
    }

    func test_passes_through_on_200() {
        let chain = MockRequestChain()
        let interceptor = RateLimitMappingInterceptor()

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 200),
            completion: { _ in }
        )

        XCTAssertEqual(chain.handleErrorCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }

    func test_passes_through_on_503() {
        let chain = MockRequestChain()
        let interceptor = RateLimitMappingInterceptor()

        interceptor.interceptAsync(
            chain: chain,
            request: InterceptorTestHelpers.makeRequest(),
            response: InterceptorTestHelpers.makeResponse(status: 503),
            completion: { _ in }
        )

        XCTAssertEqual(chain.handleErrorCount, 0)
        XCTAssertEqual(chain.proceedCount, 1)
    }
}

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
        // A date well in the past relative to `now` should yield 0, not negative.
        let now = Date(timeIntervalSince1970: 1_000_000_000) // 2001
        let result = RetryAfterParser.parse(headerValue: "Sun, 06 Nov 1994 08:49:37 GMT", now: now)
        XCTAssertEqual(result, 0)
    }
}
