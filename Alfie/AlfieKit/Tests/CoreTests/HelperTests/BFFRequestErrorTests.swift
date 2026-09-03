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

    func test_bffrequesterror_default_graphql_error_status_is_nil() {
        let sut = BFFRequestError(type: .generic)
        XCTAssertNil(sut.graphqlErrorStatus)
    }

    func test_bffrequesterror_carries_graphql_error_status() {
        let sut = BFFRequestError(type: .generic, graphqlErrorStatus: 404)
        XCTAssertEqual(sut.graphqlErrorStatus, 404)
    }

    // MARK: - Cart not found

    func test_a_404_status_maps_to_the_cart_not_found_error() {
        let sut = BFFRequestError(type: .generic, graphqlErrorStatus: 404).mappingCartNotFound()
        XCTAssertEqual(sut.type, .cart(.cartNotFound))
    }

    // The stored cart id is only discarded for a 404. A server having a bad day must keep it, or a
    // live cart is thrown away over a transient failure.
    func test_a_500_status_is_left_alone_so_the_stored_cart_id_survives_it() {
        let sut = BFFRequestError(type: .generic, graphqlErrorStatus: 500).mappingCartNotFound()
        XCTAssertEqual(sut.type, .generic)
    }

    func test_a_failure_carrying_no_status_at_all_is_left_alone() {
        // Transport failures — no internet, timeouts — never reach a GraphQL error body.
        let sut = BFFRequestError(type: .noInternet).mappingCartNotFound()
        XCTAssertEqual(sut.type, .noInternet)
    }

    func test_mapping_a_cart_not_found_keeps_the_context_the_original_carried() {
        let sut = BFFRequestError(
            type: .generic,
            message: "Cart not found",
            retryCount: 2,
            graphqlErrorCode: "NOT_FOUND",
            graphqlErrorStatus: 404
        ).mappingCartNotFound()

        XCTAssertEqual(sut.errorMessage, "Cart not found")
        XCTAssertEqual(sut.retryCount, 2)
        XCTAssertEqual(sut.graphqlErrorCode, "NOT_FOUND")
        XCTAssertEqual(sut.graphqlErrorStatus, 404)
    }

    func test_bffrequesterror_is_not_notfound_for_cart_not_found() {
        // `isNotFound` drives the product screens' "no such product" copy. A dead cart is recovered
        // from rather than shown, so it deliberately stays out.
        let sut = BFFRequestError(type: .cart(.cartNotFound))
        XCTAssertFalse(sut.isNotFound)
    }
}
