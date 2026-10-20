import Mocks
import Model
import TestUtils
import XCTest
@testable import ProductListing

final class ProductListingTransientErrorTests: XCTestCase {
    private var mockClientService: MockBFFClientService!
    private let loadedProducts = Array(Product.fixtures.prefix(3))

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
    }

    override func tearDownWithError() throws {
        mockClientService = nil
        try super.tearDownWithError()
    }

    private let rows = BFFFailureRow.all.filter { $0.plp != .noResults }

    func test_a_failed_refresh_over_loaded_products_names_the_failure_kind() async {
        for row in rows {
            let sut = makeLoadedSUT(hasNextPage: false)
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw row.error }

            await sut.refresh()

            XCTAssertEqual(sut.transientError, .init(request: .refresh, error: row.plp), row.name)
            XCTAssertTrue(sut.state.isSuccess, row.name)
            XCTAssertEqual(sut.products.map(\.id), loadedProducts.map(\.id), row.name)
        }
    }

    func test_a_failed_next_page_names_the_failure_kind() throws {
        let lastLoadedProduct = try XCTUnwrap(loadedProducts.last)
        for row in rows {
            let sut = makeLoadedSUT(hasNextPage: true)
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw row.error }

            XCTAssertEmitsValue(
                from: sut.$transientError,
                where: { $0 != nil },
                afterTrigger: { sut.didDisplay(lastLoadedProduct) }
            )

            XCTAssertEqual(sut.transientError, .init(request: .nextPage, error: row.plp), row.name)
            XCTAssertTrue(sut.state.isSuccess, row.name)
            XCTAssertEqual(sut.products.map(\.id), loadedProducts.map(\.id), row.name)
        }
    }

    func test_a_cancelled_refresh_over_loaded_products_stays_silent() async {
        for mode in [ProductListingViewMode.listing, .searchResults] {
            let sut = makeLoadedSUT(hasNextPage: false, mode: mode)
            stubBFF { throw CancellationError() }

            await sut.refresh()

            XCTAssertNil(sut.transientError, "\(mode)")
            XCTAssertTrue(sut.state.isSuccess, "\(mode)")
            XCTAssertEqual(sut.products.map(\.id), loadedProducts.map(\.id), "\(mode)")
        }
    }

    private func makeLoadedSUT(hasNextPage: Bool, mode: ProductListingViewMode = .listing) -> ProductListingViewModel {
        let products = loadedProducts
        stubBFF {
            ProductListing.fixture(
                pagination: .fixture(endCursor: "cursor-1", hasNextPage: hasNextPage),
                products: products
            )
        }
        let sut = makeSUT(mode: mode)
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { sut.viewDidAppear() })
        return sut
    }

    private func stubBFF(_ response: @escaping () throws -> ProductListing) {
        mockClientService.onProductListCalled = { _, _, _, _, _ in try response() }
        mockClientService.onSearchProductsCalled = { _, _, _, _, _ in try response() }
    }

    private func makeSUT(mode: ProductListingViewMode) -> ProductListingViewModel {
        switch mode {
        case .listing:
            return .onRealServices(bffClient: mockClientService, category: "clothing", mode: mode)

        case .searchResults:
            return .onRealServices(bffClient: mockClientService, searchText: "shirt", mode: mode)
        }
    }
}
