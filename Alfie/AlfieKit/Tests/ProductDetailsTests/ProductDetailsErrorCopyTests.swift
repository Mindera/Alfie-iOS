import Model
import SharedUI
import XCTest
@testable import ProductDetails

final class ProductDetailsErrorCopyTests: XCTestCase {
    func test_each_error_kind_shows_its_own_title_and_message() {
        let cases: [(error: ProductDetailsViewErrorType, title: String, message: String)] = [
            (.generic, L10n.Pdp.ErrorView.title, L10n.Pdp.ErrorView.Generic.message),
            (.notFound, L10n.Pdp.ErrorView.title, L10n.Pdp.ErrorView.NotFound.message),
            (.noConnection, L10n.Pdp.ErrorView.NoConnection.title, L10n.Pdp.ErrorView.NoConnection.message),
            (.rateLimited, L10n.Pdp.ErrorView.RateLimited.title, L10n.Pdp.ErrorView.RateLimited.message),
            (.serverError, L10n.Pdp.ErrorView.ServerError.title, L10n.Pdp.ErrorView.ServerError.message),
        ]

        XCTAssertEqual(cases.count, ProductDetailsViewErrorType.allCases.count)
        for (error, title, message) in cases {
            XCTAssertEqual(error.title, title, "\(error)")
            XCTAssertEqual(error.message, message, "\(error)")
        }
    }
}
