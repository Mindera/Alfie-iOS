import Mocks
import Model
import TestUtils
import XCTest
@testable import Core

final class ProductListingServiceTests: XCTestCase {
    private var sut: ProductListingService!
    private var mockClientService: MockBFFClientService!
    private let pageSize = ProductListingService.PaginationConfiguration(type: .plp).pageSize

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
        sut = .init(
            productService: ProductService(bffClient: mockClientService),
            configuration: .init(type: .plp)
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClientService = nil
        try super.tearDownWithError()
    }

    func test_first_page_calls_bff_service_with_nil_cursor_and_no_filters() async throws {
        var captured: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            captured = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture()
        }

        _ = try await sut.paged(categoryId: "category id", query: "query", sort: "sort", filters: nil)

        let call = try XCTUnwrap(captured)
        XCTAssertNil(call.after)
        XCTAssertEqual(call.limit, pageSize)
        XCTAssertEqual(call.categoryId, "category id")
        XCTAssertEqual(call.query, "query")
        XCTAssertEqual(call.sort, "sort")
        XCTAssertNil(call.filters)
    }

    func test_first_page_forwards_filters() async throws {
        var captured: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            captured = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"], minPrice: 10, productTypes: ["Shoes"])

        _ = try await sut.paged(filters: filters)

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.filters, filters)
    }

    func test_pagination_info_provides_next_page() async throws {
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in
            ProductListing.fixture(pagination: .fixture(endCursor: "cursor-1", hasNextPage: true))
        }

        _ = try await sut.paged()

        XCTAssertTrue(sut.hasNext())
    }

    func test_pagination_info_provides_total_records() async throws {
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in
            ProductListing.fixture(pagination: .fixture(totalCount: 101))
        }

        _ = try await sut.paged()

        XCTAssertEqual(sut.totalOfRecords, 101)
    }

    func test_next_throws_when_no_next_page() async throws {
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in
            ProductListing.fixture(pagination: .fixture(endCursor: nil, hasNextPage: false))
        }
        _ = try await sut.paged()
        XCTAssertFalse(sut.hasNext())

        do {
            _ = try await sut.next()
            XCTFail("next() should throw when no cursor is available")
        } catch let error as BFFRequestError {
            guard case .product(.noProducts) = error.type else {
                XCTFail("Unexpected BFFRequestError type: \(error.type)")
                return
            }
        }
    }

    func test_next_page_forwards_stored_cursor_and_filters() async throws {
        let filters = ProductFilterInput(brandNames: ["Acme"])

        var firstCall: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            firstCall = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture(pagination: .fixture(endCursor: "cursor-A", hasNextPage: true))
        }
        _ = try await sut.paged(filters: filters)
        XCTAssertNil(try XCTUnwrap(firstCall).after)
        XCTAssertTrue(sut.hasNext())

        var secondCall: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            secondCall = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture(pagination: .fixture(endCursor: nil, hasNextPage: false))
        }
        _ = try await sut.next(filters: filters)
        let second = try XCTUnwrap(secondCall)
        XCTAssertEqual(second.after, "cursor-A")
        XCTAssertEqual(second.filters, filters)
        XCTAssertFalse(sut.hasNext())
    }

    func test_next_throws_when_called_before_paged() async {
        do {
            _ = try await sut.next(categoryId: "cat", query: "q", sort: "s")
            XCTFail("Expected next() to throw when no cursor is set")
        } catch let error as BFFRequestError {
            guard case .product(.noProducts(let category, let query, let sort)) = error.type else {
                XCTFail("Unexpected BFFRequestError type: \(error.type)")
                return
            }
            XCTAssertEqual(category, "cat")
            XCTAssertEqual(query, "q")
            XCTAssertEqual(sort, "s")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Helpers

private struct ProductListingCall {
    let after: String?
    let limit: Int
    let categoryId: String?
    let query: String?
    let sort: String?
    let filters: ProductFilterInput?
}
