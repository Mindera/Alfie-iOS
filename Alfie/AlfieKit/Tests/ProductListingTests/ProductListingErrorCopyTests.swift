import Model
import XCTest
@testable import ProductListing

final class ProductListingErrorCopyTests: XCTestCase {
    func test_each_error_kind_shows_its_own_title_and_message() {
        let cases: [(error: ProductListingViewErrorType, title: String, message: String)] = [
            (.generic, "Cannot load products", "Please try again later"),
            (.noResults, "Cannot load products", "Please try again later"),
            (.noConnection, "No connection", "Check your connection and try again."),
            (.rateLimited, "Too many requests", "Please wait a moment and try again."),
            (.serverError, "Service unavailable", "We're having trouble reaching our servers. Please try again."),
        ]

        XCTAssertEqual(cases.count, ProductListingViewErrorType.allCases.count)
        for (error, title, message) in cases {
            XCTAssertEqual(error.title, title, "\(error)")
            XCTAssertEqual(error.message, message, "\(error)")
        }
    }
}
