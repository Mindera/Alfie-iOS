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

    func test_page_forwards_args_to_bff() async throws {
        var captured: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            captured = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"])

        _ = try await sut.page(after: "cursor-1", categoryId: "category", query: "q", sort: "s", filters: filters)

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, pageSize)
        XCTAssertEqual(call.categoryId, "category")
        XCTAssertEqual(call.query, "q")
        XCTAssertEqual(call.sort, "s")
        XCTAssertEqual(call.filters, filters)
    }

    func test_page_with_nil_cursor_loads_first_page() async throws {
        var captured: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            captured = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture()
        }

        _ = try await sut.page(after: nil, categoryId: "category", query: nil, sort: nil, filters: nil)

        XCTAssertNil(try XCTUnwrap(captured).after)
    }

    func test_page_returns_the_full_listing_unchanged() async throws {
        let expected = ProductListing.fixture(
            pagination: .fixture(totalCount: 7, endCursor: "abc", hasNextPage: true),
            products: [Product.fixture(), Product.fixture(), Product.fixture()]
        )
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in expected }

        let listing = try await sut.page(after: nil, categoryId: "c", query: nil, sort: nil, filters: nil)

        XCTAssertEqual(listing.products.count, expected.products.count)
        XCTAssertEqual(listing.pagination.totalCount, 7)
        XCTAssertEqual(listing.pagination.endCursor, "abc")
        XCTAssertTrue(listing.pagination.hasNextPage)
    }

    func test_page_propagates_bff_errors() async {
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in
            throw BFFRequestError(type: .generic)
        }

        do {
            _ = try await sut.page(after: nil, categoryId: "c", query: nil, sort: nil, filters: nil)
            XCTFail("Expected page() to throw")
        } catch let error as BFFRequestError {
            // ProductService maps non-emptyResponse BFF errors to .product(.generic)
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
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
