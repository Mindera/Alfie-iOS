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

    func test_a_failed_category_first_page_names_the_failure_kind() {
        for row in BFFFailureRow.all {
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw row.error }
            let sut = makeSUT(category: "clothing", mode: .listing)

            XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { sut.viewDidAppear() })

            XCTAssertEqual(sut.state.failure, row.plp, row.name)
        }
    }

    func test_a_failed_search_first_page_names_the_failure_kind() {
        for row in BFFFailureRow.all {
            mockClientService.onSearchProductsCalled = { _, _, _, _, _ in throw row.error }
            let sut = makeSUT(searchText: "polo", mode: .searchResults)

            XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { sut.viewDidAppear() })

            XCTAssertEqual(sut.state.failure, row.plp, row.name)
        }
    }

    func test_a_failed_refresh_with_no_loaded_products_names_the_failure_kind() async {
        for row in BFFFailureRow.all {
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw row.error }
            let sut = makeSUT(category: "clothing", mode: .listing)

            await sut.refresh()

            XCTAssertEqual(sut.state.failure, row.plp, row.name)
            XCTAssertNil(sut.transientError, row.name)
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
