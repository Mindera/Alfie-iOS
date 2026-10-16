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

    private let cases: [(name: String, error: BFFRequestError, expected: ProductListingViewErrorType)] = [
        ("server error", BFFRequestError(type: .serverError(status: 503)), .serverError),
        ("rate limited", BFFRequestError(type: .rateLimited(retryAfter: 5)), .rateLimited),
        ("no connection", BFFRequestError(type: .noInternet), .noConnection),
        ("timeout", BFFRequestError(type: .timeout), .generic),
        ("generic", BFFRequestError(type: .generic), .generic),
    ]

    func test_a_failed_refresh_over_loaded_products_names_the_failure_kind() async {
        for (name, error, expected) in cases {
            let sut = makeLoadedSUT(hasNextPage: false)
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw error }

            await sut.refresh()

            XCTAssertEqual(sut.transientError, .init(request: .refresh, error: expected), name)
            XCTAssertTrue(sut.state.isSuccess, name)
            XCTAssertEqual(sut.products.map(\.id), loadedProducts.map(\.id), name)
        }
    }

    func test_a_failed_next_page_names_the_failure_kind() {
        for (name, error, expected) in cases {
            let sut = makeLoadedSUT(hasNextPage: true)
            mockClientService.onProductListCalled = { _, _, _, _, _ in throw error }

            XCTAssertEmitsValue(
                from: sut.$transientError,
                where: { $0 != nil },
                afterTrigger: { sut.didDisplay(sut.products.last!) }
            )

            XCTAssertEqual(sut.transientError, .init(request: .nextPage, error: expected), name)
            XCTAssertTrue(sut.state.isSuccess, name)
            XCTAssertEqual(sut.products.map(\.id), loadedProducts.map(\.id), name)
        }
    }

    private func makeLoadedSUT(hasNextPage: Bool) -> ProductListingViewModel {
        let products = loadedProducts
        mockClientService.onProductListCalled = { _, _, _, _, _ in
            ProductListing.fixture(
                pagination: .fixture(endCursor: "cursor-1", hasNextPage: hasNextPage),
                products: products
            )
        }
        let sut = makeSUT()
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { sut.viewDidAppear() })
        return sut
    }

    private func makeSUT() -> ProductListingViewModel {
        .onRealServices(bffClient: mockClientService, category: "clothing", mode: .listing)
    }
}
