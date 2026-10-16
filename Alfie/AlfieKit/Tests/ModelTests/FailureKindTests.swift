import Model
import XCTest

final class FailureKindTests: XCTestCase {
    private let productionFailures: [(name: String, error: Error, kind: FailureKind)] = [
        ("server error", BFFRequestError(type: .serverError(status: 503), retryCount: 2), .serverError),
        ("rate limited", BFFRequestError(type: .rateLimited(retryAfter: 5)), .rateLimited),
        ("rate limited without retry-after", BFFRequestError(type: .rateLimited(retryAfter: nil)), .rateLimited),
        ("no connection", BFFRequestError(type: .noInternet), .noConnection),
        ("timeout", BFFRequestError(type: .timeout), .generic),
        ("generic", BFFRequestError(type: .generic), .generic),
        ("cart not found", BFFRequestError(type: .cart(.cartNotFound)), .generic),
        ("empty response", BFFRequestError(type: .emptyResponse), .generic),
        ("product not found", BFFRequestError(type: .product(.noProduct)), .generic),
        ("non-BFF error", URLError(.badServerResponse), .generic),
    ]

    func test_every_production_failure_maps_to_its_failure_kind() {
        for failure in productionFailures {
            XCTAssertEqual(FailureKind(error: failure.error), failure.kind, failure.name)
        }
    }

    func test_plp_shows_no_results_for_not_found_and_the_failure_kind_otherwise() {
        let expected: [String: ProductListingViewErrorType] = [
            "server error": .serverError,
            "rate limited": .rateLimited,
            "rate limited without retry-after": .rateLimited,
            "no connection": .noConnection,
            "empty response": .noResults,
            "product not found": .noResults,
        ]

        for failure in productionFailures {
            XCTAssertEqual(
                ProductListingViewErrorType.from(error: failure.error),
                expected[failure.name] ?? .generic,
                failure.name
            )
        }
    }

    func test_pdp_shows_not_found_for_not_found_and_the_failure_kind_otherwise() {
        let expected: [String: ProductDetailsViewErrorType] = [
            "server error": .serverError,
            "rate limited": .rateLimited,
            "rate limited without retry-after": .rateLimited,
            "no connection": .noConnection,
            "empty response": .notFound,
            "product not found": .notFound,
        ]

        for failure in productionFailures {
            XCTAssertEqual(
                ProductDetailsViewErrorType.from(error: failure.error),
                expected[failure.name] ?? .generic,
                failure.name
            )
        }
    }

    func test_categories_show_the_failure_kind() {
        let expected: [String: CategoriesViewErrorType] = [
            "server error": .serverError,
            "rate limited": .rateLimited,
            "rate limited without retry-after": .rateLimited,
            "no connection": .noConnection,
        ]

        for failure in productionFailures {
            XCTAssertEqual(
                CategoriesViewErrorType.from(error: failure.error),
                expected[failure.name] ?? .generic,
                failure.name
            )
        }
    }
}
