import Foundation
import Model
import XCTest

/// All four feature error enums (PLP, PDP, Categories, Brands) map from
/// `BFFRequestError` via a `from(error:)` helper. The mapping is symmetric across
/// features for transient categories (rate-limit, server-error, no-internet,
/// generic, non-BFF) and only diverges for "no results / not found" semantics.
/// One driver covers all four — if a future feature adds a new BFF case, every
/// suite fails until the mapping is updated everywhere.
final class ViewErrorTypeMappingTests: XCTestCase {
    // MARK: - PLP

    func test_plp_mapping() {
        assertCommonMapping(
            from: ProductListingViewErrorType.from(error:),
            rateLimited: .rateLimited,
            serverError: .serverError,
            noInternet: .noInternet,
            generic: .generic,
            nonBFFFallback: .generic
        )
        // "No products found" maps to the empty-results state, not generic.
        XCTAssertEqual(ProductListingViewErrorType.from(error: BFFRequestError(type: .product(.noProduct))), .noResults)
        XCTAssertEqual(
            ProductListingViewErrorType.from(error: BFFRequestError(type: .product(.noProducts(category: nil, query: nil, sort: nil)))),
            .noResults
        )
    }

    // MARK: - PDP

    func test_pdp_mapping() {
        assertCommonMapping(
            from: ProductDetailsViewErrorType.from(error:),
            rateLimited: .rateLimited,
            serverError: .serverError,
            noInternet: .noInternet,
            generic: .generic,
            nonBFFFallback: .generic
        )
        // PDP uses .notFound for product-not-found and empty-response shapes.
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .product(.noProduct))), .notFound)
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .emptyResponse)), .notFound)
    }

    // MARK: - Categories

    func test_categories_mapping() {
        assertCommonMapping(
            from: CategoriesViewErrorType.from(error:),
            rateLimited: .rateLimited,
            serverError: .serverError,
            noInternet: .noInternet,
            generic: .generic,
            nonBFFFallback: .generic
        )
    }

    // MARK: - Brands

    func test_brands_mapping() {
        assertCommonMapping(
            from: BrandsViewErrorType.from(error:),
            rateLimited: .rateLimited,
            serverError: .serverError,
            noInternet: .noInternet,
            generic: .generic,
            nonBFFFallback: .generic
        )
    }

    // MARK: - Shared driver

    private func assertCommonMapping<Mapped: Equatable>(
        from map: (Error) -> Mapped,
        rateLimited: Mapped,
        serverError: Mapped,
        noInternet: Mapped,
        generic: Mapped,
        nonBFFFallback: Mapped,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(map(BFFRequestError(type: .rateLimited(retryAfter: 5))), rateLimited, "rateLimited", file: file, line: line)
        XCTAssertEqual(map(BFFRequestError(type: .rateLimited(retryAfter: nil))), rateLimited, "rateLimited(nil)", file: file, line: line)
        XCTAssertEqual(map(BFFRequestError(type: .serverError(status: 503))), serverError, "serverError", file: file, line: line)
        XCTAssertEqual(map(BFFRequestError(type: .serverError(status: 500))), serverError, "serverError(500)", file: file, line: line)
        XCTAssertEqual(map(BFFRequestError(type: .noInternet)), noInternet, "noInternet", file: file, line: line)
        XCTAssertEqual(map(BFFRequestError(type: .generic)), generic, "generic", file: file, line: line)
        XCTAssertEqual(map(BFFRequestError(type: .timeout)), generic, "timeout falls back to generic for v1", file: file, line: line)

        XCTAssertEqual(map(NotABFFError()), nonBFFFallback, "non-BFF error falls back", file: file, line: line)
    }
}

private struct NotABFFError: Error {}
