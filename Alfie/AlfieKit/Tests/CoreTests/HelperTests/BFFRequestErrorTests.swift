import XCTest
import Model

final class BFFRequestErrorTests: XCTestCase {
    func test_bffrequesterror_is_not_found_for_no_product_error() {
        let sut = BFFRequestError(type: .product(.noProduct))
        XCTAssertTrue(sut.isNotFound)
    }

    func test_bffrequesterror_is_notfound_for_no_products_error() {
        let sut = BFFRequestError(type: .product(.noProducts(category: nil, query: nil, sort: nil)))
        XCTAssertTrue(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_generic_products_error() {
        let sut = BFFRequestError(type: .product(.generic))
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_found_for_empty_response_error() {
        let sut = BFFRequestError(type: .emptyResponse)
        XCTAssertTrue(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_no_internet_error() {
        let sut = BFFRequestError(type: .noInternet)
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_generic_error() {
        let sut = BFFRequestError(type: .generic)
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_rate_limited_error() {
        let sut = BFFRequestError(type: .rateLimited(retryAfter: 5))
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_timeout_error() {
        let sut = BFFRequestError(type: .timeout)
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_server_error() {
        let sut = BFFRequestError(type: .serverError(status: 503))
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_rate_limited_cases_equal_with_same_retry_after() {
        XCTAssertEqual(
            BFFRequestError.BFFRequestErrorType.rateLimited(retryAfter: 5),
            BFFRequestError.BFFRequestErrorType.rateLimited(retryAfter: 5)
        )
        XCTAssertEqual(
            BFFRequestError.BFFRequestErrorType.rateLimited(retryAfter: nil),
            BFFRequestError.BFFRequestErrorType.rateLimited(retryAfter: nil)
        )
        XCTAssertNotEqual(
            BFFRequestError.BFFRequestErrorType.rateLimited(retryAfter: 5),
            BFFRequestError.BFFRequestErrorType.rateLimited(retryAfter: 10)
        )
    }

    func test_bffrequesterror_server_error_cases_equal_with_same_status() {
        XCTAssertEqual(
            BFFRequestError.BFFRequestErrorType.serverError(status: 503),
            BFFRequestError.BFFRequestErrorType.serverError(status: 503)
        )
        XCTAssertNotEqual(
            BFFRequestError.BFFRequestErrorType.serverError(status: 500),
            BFFRequestError.BFFRequestErrorType.serverError(status: 503)
        )
    }

    func test_bffrequesterror_default_retry_count_is_zero() {
        let sut = BFFRequestError(type: .generic)
        XCTAssertEqual(sut.retryCount, 0)
    }

    func test_bffrequesterror_carries_retry_count() {
        let sut = BFFRequestError(type: .serverError(status: 503), retryCount: 3)
        XCTAssertEqual(sut.retryCount, 3)
    }

    func test_bffrequesterror_default_graphql_error_code_is_nil() {
        let sut = BFFRequestError(type: .generic)
        XCTAssertNil(sut.graphqlErrorCode)
    }

    func test_bffrequesterror_carries_graphql_error_code() {
        let sut = BFFRequestError(type: .rateLimited(retryAfter: nil), graphqlErrorCode: "RATE_LIMITED")
        XCTAssertEqual(sut.graphqlErrorCode, "RATE_LIMITED")
    }
}
