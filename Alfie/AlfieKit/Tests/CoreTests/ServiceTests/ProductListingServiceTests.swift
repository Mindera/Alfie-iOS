import Combine
import TestUtils
import Mocks
import Models
import XCTest
@testable import Core

final class ProductListingServiceTests: XCTestCase {
    private var sut: ProductListingService!
    private var mockClientService: MockBFFClientService!
    private var paginationConfiguration: ProductListingService.PaginationConfiguration!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
        paginationConfiguration = .init(type: .plp, initialPage: 0)
        sut = .init(
            productService: ProductService(bffClient: mockClientService),
            configuration: paginationConfiguration
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClientService = nil
        try super.tearDownWithError()
    }

    func test_first_page_calls_bff_service_with_params() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { offset, limit, categoryId, query, sort in
            XCTAssertEqual(offset, self.paginationConfiguration.initialPage)
            XCTAssertEqual(limit, self.paginationConfiguration.pageSize)
            XCTAssertEqual(categoryId, "category id")
            XCTAssertEqual(query, "query")
            XCTAssertEqual(sort, "sort")
            expectation.fulfill()
            return ProductListing.fixture()
        }

        Task {
            _ = try await sut.paged(categoryId: "category id", query: "query", sort: "sort")
        }

        wait(for: [expectation], timeout: `default`)
    }

    func test_pagination_info_provides_next_page() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            expectation.fulfill()
            return ProductListing.fixture(pagination: .fixture(nextPage: 1))
        }

        Task {
            _ = try await sut.paged()
        }

        wait(for: [expectation], timeout: `default`)
        XCTAssertTrue(sut.hasNext())
    }

    func test_pagination_info_provides_total_records() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            expectation.fulfill()
            return ProductListing.fixture(pagination: .fixture(total: 101))
        }

        Task {
            _ = try await sut.paged()
        }

        wait(for: [expectation], timeout: `default`)
        XCTAssertEqual(sut.totalOfRecords, 101)
    }

    func test_doesnt_call_next_page_when_no_next_page() {
        let calledExpectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            calledExpectation.fulfill()
            return ProductListing.fixture(pagination: .fixture(nextPage: nil))
        }

        Task {
            _ = try await sut.paged()
        }

        wait(for: [calledExpectation], timeout: `default`)

        XCTAssertFalse(sut.hasNext())

        let notCalledExpectation = expectation(description: "Wait for no service call")
        notCalledExpectation.isInverted = true
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            notCalledExpectation.fulfill()
            return ProductListing.fixture()
        }

        Task {
            _ = try await sut.next()
        }

        wait(for: [notCalledExpectation], timeout: inverted)
    }

    func test_next_page_calls_bff_service_while_has_next_pages() async {
        let expectation = expectation(description: "Wait for service call for 2 pages")
        expectation.expectedFulfillmentCount = 2
        mockClientService.onProductListingCalled = { offset, _, _, _, _ in
            expectation.fulfill()
            return ProductListing.fixture(pagination: .fixture(nextPage: offset < 1 ? offset + 1 : nil))
        }

        do {
            // first page successfully
            _ = try await sut.paged(categoryId: "try 1", query: "query 1", sort: "sort 1")
            XCTAssertTrue(sut.hasNext())
            // second page successfully but no next page
            _ = try await sut.next(categoryId: "try 2", query: "query 2", sort: "sort 2")
            XCTAssertFalse(sut.hasNext())
            // third page failure
            _ = try await sut.next(categoryId: "try 3", query: "query 3", sort: "sort 3")
        } catch {
            guard case let bffError = error as? BFFRequestError,
                  case .product(let productError) = bffError?.type,
                  case .noProducts(let category, let query, let sort) = productError
            else {
                XCTFail("Unexpected error thrown")
                return
            }
            XCTAssertEqual(category, "try 3")
            XCTAssertEqual(query, "query 3")
            XCTAssertEqual(sort, "sort 3")
        }

        await fulfillment(of: [expectation], timeout: `default`)
    }
}
