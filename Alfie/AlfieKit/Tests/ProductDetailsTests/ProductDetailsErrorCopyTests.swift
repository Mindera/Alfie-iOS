import Model
import XCTest
@testable import ProductDetails

final class ProductDetailsErrorCopyTests: XCTestCase {
    func test_each_error_kind_shows_its_own_title_and_message() {
        let cases: [(error: ProductDetailsViewErrorType, title: String, message: String)] = [
            (.generic, "Oops!", "Something went wrong."),
            (.notFound, "Oops!", "The page you are looking for doesn’t exist."),
            (.noConnection, "No connection", "Check your connection."),
            (.rateLimited, "Too many requests", "Please wait a moment and try again."),
            (.serverError, "Service unavailable", "We're having trouble reaching our servers. Please try again."),
        ]

        XCTAssertEqual(cases.count, ProductDetailsViewErrorType.allCases.count)
        for (error, title, message) in cases {
            XCTAssertEqual(error.title, title, "\(error)")
            XCTAssertEqual(error.message, message, "\(error)")
        }
    }
}
