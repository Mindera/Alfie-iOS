import Model
import XCTest

final class FailureKindTests: XCTestCase {
    private struct ProductionFailure {
        let name: String
        let error: Error
        let kind: FailureKind
        let plp: ProductListingViewErrorType
        let pdp: ProductDetailsViewErrorType
        let categories: CategoriesViewErrorType
    }

    private let productionFailures: [ProductionFailure] = [
        .init(
            name: "server error",
            error: BFFRequestError(type: .serverError(status: 503), retryCount: 2),
            kind: .serverError,
            plp: .serverError,
            pdp: .serverError,
            categories: .serverError
        ),
        .init(
            name: "rate limited",
            error: BFFRequestError(type: .rateLimited(retryAfter: 5)),
            kind: .rateLimited,
            plp: .rateLimited,
            pdp: .rateLimited,
            categories: .rateLimited
        ),
        .init(
            name: "rate limited without retry-after",
            error: BFFRequestError(type: .rateLimited(retryAfter: nil)),
            kind: .rateLimited,
            plp: .rateLimited,
            pdp: .rateLimited,
            categories: .rateLimited
        ),
        .init(
            name: "no connection",
            error: BFFRequestError(type: .noInternet),
            kind: .noConnection,
            plp: .noConnection,
            pdp: .noConnection,
            categories: .noConnection
        ),
        .init(
            name: "timeout",
            error: BFFRequestError(type: .timeout),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
        .init(
            name: "generic",
            error: BFFRequestError(type: .generic),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
        .init(
            name: "cart not found",
            error: BFFRequestError(type: .cart(.cartNotFound)),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
        .init(
            name: "empty response",
            error: BFFRequestError(type: .emptyResponse),
            kind: .generic,
            plp: .noResults,
            pdp: .notFound,
            categories: .generic
        ),
        .init(
            name: "product not found",
            error: BFFRequestError(type: .product(.noProduct)),
            kind: .generic,
            plp: .noResults,
            pdp: .notFound,
            categories: .generic
        ),
        .init(
            name: "non-BFF error",
            error: URLError(.badServerResponse),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
    ]

    func test_every_production_failure_maps_to_its_failure_kind() {
        for failure in productionFailures {
            XCTAssertEqual(FailureKind(error: failure.error), failure.kind, failure.name)
        }
    }

    func test_plp_shows_no_results_for_not_found_and_the_failure_kind_otherwise() {
        for failure in productionFailures {
            XCTAssertEqual(ProductListingViewErrorType.from(error: failure.error), failure.plp, failure.name)
        }
    }

    func test_pdp_shows_not_found_for_not_found_and_the_failure_kind_otherwise() {
        for failure in productionFailures {
            XCTAssertEqual(ProductDetailsViewErrorType.from(error: failure.error), failure.pdp, failure.name)
        }
    }

    func test_categories_show_the_failure_kind() {
        for failure in productionFailures {
            XCTAssertEqual(CategoriesViewErrorType.from(error: failure.error), failure.categories, failure.name)
        }
    }
}
