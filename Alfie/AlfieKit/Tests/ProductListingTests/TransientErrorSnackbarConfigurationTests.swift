import Model
import SharedUI
import XCTest
@testable import ProductListing

final class TransientErrorSnackbarConfigurationTests: XCTestCase {
    func test_next_page_error_shows_the_next_page_message() {
        let sut = makeSUT(request: .nextPage)

        XCTAssertEqual(sut.text, "Couldn't load more products.")
    }

    func test_refresh_error_shows_the_refresh_message() {
        let sut = makeSUT(request: .refresh)

        XCTAssertEqual(sut.text, "Couldn't refresh. Please try again.")
    }

    func test_a_typed_failure_shows_one_message_per_kind_on_refresh_and_next_page() {
        let cases: [(error: ProductListingViewErrorType, expected: String)] = [
            (.serverError, "We're having trouble."),
            (.rateLimited, "Please wait a moment."),
            (.noConnection, "Check your connection."),
        ]
        for (error, expected) in cases {
            for request in [ProductListingTransientError.Request.refresh, .nextPage] {
                XCTAssertEqual(makeSUT(request: request, error: error).text, expected, "\(error) on \(request)")
            }
        }
    }

    func test_transient_error_offers_retry_and_stays_until_dismissed() {
        let sut = makeSUT(request: .nextPage)

        XCTAssertEqual(sut.actionButtonLabel, "Retry")
        XCTAssertNil(sut.autoDismissTime)
        XCTAssertTrue(sut.showCloseButton)
    }

    func test_tapping_retry_calls_on_retry() {
        var didRetry = false
        let sut = makeSUT(request: .nextPage, onRetry: { didRetry = true })

        sut.onActionTap?()

        XCTAssertTrue(didRetry)
    }

    private func makeSUT(
        request: ProductListingTransientError.Request,
        error: ProductListingViewErrorType = .generic,
        onRetry: @escaping () -> Void = {}
    ) -> SnackbarViewConfiguration {
        .transientError(.init(request: request, error: error), onRetry: onRetry, onDismiss: {})
    }
}
