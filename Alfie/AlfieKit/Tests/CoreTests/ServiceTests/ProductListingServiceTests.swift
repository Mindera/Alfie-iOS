import Combine
import TestUtils
import Mocks
import Model
import XCTest
@testable import Core

final class ProductListingServiceTests: XCTestCase {
    private var sut: ProductListingService!
    private var mockClientService: MockBFFClientService!
    private var paginationConfiguration: ProductListingService.PaginationConfiguration!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
        paginationConfiguration = .init(type: .plp)
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

    func test_first_page_calls_bff_service_with_nil_cursor() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort in
            XCTAssertNil(after)
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

        wait(for: [expectation], timeout: .default)
    }

    func test_pagination_info_provides_next_page() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            expectation.fulfill()
            return ProductListing.fixture(pagination: .fixture(endCursor: "cursor-1", hasNextPage: true))
        }

        Task {
            _ = try await sut.paged()
        }

        wait(for: [expectation], timeout: .default)
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

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(sut.totalOfRecords, 101)
    }

    func test_doesnt_call_next_page_when_no_next_page() {
        let calledExpectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            calledExpectation.fulfill()
            return ProductListing.fixture(pagination: .fixture(endCursor: nil, hasNextPage: false))
        }

        Task {
            _ = try await sut.paged()
        }

        wait(for: [calledExpectation], timeout: .default)

        XCTAssertFalse(sut.hasNext())

        let notCalledExpectation = expectation(description: "Wait for no service call")
        notCalledExpectation.isInverted = true
        mockClientService.onProductListingCalled = { _, _, _, _, _ in
            notCalledExpectation.fulfill()
            return ProductListing.fixture()
        }

        Task {
            _ = try? await sut.next()
        }

        wait(for: [notCalledExpectation], timeout: .inverted)
    }

    func test_next_page_forwards_stored_cursor() async throws {
        let firstCall = expectation(description: "First page")
        mockClientService.onProductListingCalled = { after, _, _, _, _ in
            XCTAssertNil(after)
            firstCall.fulfill()
            return ProductListing.fixture(pagination: .fixture(endCursor: "cursor-A", hasNextPage: true))
        }
        _ = try await sut.paged()
        await fulfillment(of: [firstCall], timeout: .default)
        XCTAssertTrue(sut.hasNext())

        let secondCall = expectation(description: "Second page")
        mockClientService.onProductListingCalled = { after, _, _, _, _ in
            XCTAssertEqual(after, "cursor-A")
            secondCall.fulfill()
            return ProductListing.fixture(pagination: .fixture(endCursor: nil, hasNextPage: false))
        }
        _ = try await sut.next()
        await fulfillment(of: [secondCall], timeout: .default)
        XCTAssertFalse(sut.hasNext())
    }

    func test_next_throws_when_no_cursor_available() async {
        do {
            _ = try await sut.next(categoryId: "cat", query: "q", sort: "s")
            XCTFail("Expected next() to throw when no cursor is set")
        } catch {
            guard let bffError = error as? BFFRequestError,
                  case .product(let productError) = bffError.type,
                  case .noProducts(let category, let query, let sort) = productError
            else {
                XCTFail("Unexpected error thrown: \(error)")
                return
            }
            XCTAssertEqual(category, "cat")
            XCTAssertEqual(query, "q")
            XCTAssertEqual(sort, "s")
        }
    }
}
