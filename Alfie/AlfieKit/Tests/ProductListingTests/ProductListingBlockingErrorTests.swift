import Mocks
import Model
import TestUtils
import XCTest
@testable import ProductListing

final class ProductListingBlockingErrorTests: XCTestCase {
    private var mockClientService: MockBFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
    }

    override func tearDownWithError() throws {
        mockClientService = nil
        try super.tearDownWithError()
    }

    private let cases: [(name: String, error: BFFRequestError, expected: ProductListingViewErrorType)] = [
        ("server error", BFFRequestError(type: .serverError(status: 503)), .serverError),
        ("rate limited", BFFRequestError(type: .rateLimited(retryAfter: 5)), .rateLimited),
        ("no connection", BFFRequestError(type: .noInternet), .noConnection),
        ("timeout", BFFRequestError(type: .timeout), .generic),
        ("generic", BFFRequestError(type: .generic), .generic),
        ("no results", BFFRequestError(type: .emptyResponse), .noResults),
    ]

    func test_a_failed_category_first_page_names_the_failure_kind() {
        for (name, error, expected) in cases {
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw error }
            let sut = makeSUT(category: "clothing", mode: .listing)

            XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { sut.viewDidAppear() })

            XCTAssertEqual(sut.state.failure, expected, name)
        }
    }

    func test_a_failed_search_first_page_names_the_failure_kind() {
        for (name, error, expected) in cases {
            mockClientService.onSearchProductsCalled = { _, _, _, _, _ in throw error }
            let sut = makeSUT(searchText: "polo", mode: .searchResults)

            XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { sut.viewDidAppear() })

            XCTAssertEqual(sut.state.failure, expected, name)
        }
    }

    func test_a_failed_refresh_with_no_loaded_products_names_the_failure_kind() async {
        for (name, error, expected) in cases {
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw error }
            let sut = makeSUT(category: "clothing", mode: .listing)

            await sut.refresh()

            XCTAssertEqual(sut.state.failure, expected, name)
            XCTAssertNil(sut.transientError, name)
        }
    }

    private func makeSUT(
        category: String? = nil,
        searchText: String? = nil,
        mode: ProductListingViewMode
    ) -> ProductListingViewModel {
        .onRealServices(bffClient: mockClientService, category: category, searchText: searchText, mode: mode)
    }
}
