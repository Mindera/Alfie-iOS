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
            searchService: SearchService(bffClient: mockClientService),
            configuration: .init(type: .plp)
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClientService = nil
        try super.tearDownWithError()
    }

    // MARK: - productListPage

    func test_productListPage_forwards_args_to_bff() async throws {
        var captured: ProductListCall?
        mockClientService.onProductListCalled = { collectionHandle, after, limit, sort, filters in
            captured = ProductListCall(collectionHandle: collectionHandle, after: after, limit: limit, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"])

        _ = try await sut.productListPage(collectionHandle: "category", after: "cursor-1", sort: "s", filters: filters)

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.collectionHandle, "category")
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, pageSize)
        XCTAssertEqual(call.sort, "s")
        XCTAssertEqual(call.filters, filters)
    }

    func test_productListPage_with_nil_cursor_loads_first_page() async throws {
        var captured: ProductListCall?
        mockClientService.onProductListCalled = { collectionHandle, after, limit, sort, filters in
            captured = ProductListCall(collectionHandle: collectionHandle, after: after, limit: limit, sort: sort, filters: filters)
            return ProductListing.fixture()
        }

        _ = try await sut.productListPage(collectionHandle: "category", after: nil, sort: nil, filters: nil)

        XCTAssertNil(try XCTUnwrap(captured).after)
    }

    func test_productListPage_returns_the_full_listing_unchanged() async throws {
        let expected = ProductListing.fixture(
            pagination: .fixture(totalCount: 7, endCursor: "abc", hasNextPage: true),
            products: [Product.fixture(), Product.fixture(), Product.fixture()]
        )
        mockClientService.onProductListCalled = { _, _, _, _, _ in expected }

        let listing = try await sut.productListPage(collectionHandle: "c", after: nil, sort: nil, filters: nil)

        XCTAssertEqual(listing.products.count, expected.products.count)
        XCTAssertEqual(listing.pagination.totalCount, 7)
        XCTAssertEqual(listing.pagination.endCursor, "abc")
        XCTAssertTrue(listing.pagination.hasNextPage)
    }

    func test_productListPage_propagates_bff_errors() async {
        mockClientService.onProductListCalled = { _, _, _, _, _ in
            throw BFFRequestError(type: .generic)
        }

        do {
            _ = try await sut.productListPage(collectionHandle: "c", after: nil, sort: nil, filters: nil)
            XCTFail("Expected productListPage() to throw")
        } catch let error as BFFRequestError {
            // ProductService maps non-emptyResponse BFF errors to .product(.generic)
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - searchPage

    func test_searchPage_forwards_args_to_bff() async throws {
        var captured: SearchCall?
        mockClientService.onSearchProductsCalled = { searchTerm, after, limit, sort, filters in
            captured = SearchCall(searchTerm: searchTerm, after: after, limit: limit, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"])

        _ = try await sut.searchPage(searchTerm: "polo", after: "cursor-1", sort: "s", filters: filters)

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.searchTerm, "polo")
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, pageSize)
        XCTAssertEqual(call.sort, "s")
        XCTAssertEqual(call.filters, filters)
    }

    func test_searchPage_propagates_bff_errors() async {
        mockClientService.onSearchProductsCalled = { _, _, _, _, _ in
            throw BFFRequestError(type: .generic)
        }

        do {
            _ = try await sut.searchPage(searchTerm: "polo", after: nil, sort: nil, filters: nil)
            XCTFail("Expected searchPage() to throw")
        } catch let error as BFFRequestError {
            // SearchService maps non-emptyResponse BFF errors to .product(.generic)
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Helpers

private struct ProductListCall {
    let collectionHandle: String
    let after: String?
    let limit: Int
    let sort: String?
    let filters: ProductFilterInput?
}

private struct SearchCall {
    let searchTerm: String
    let after: String?
    let limit: Int
    let sort: String?
    let filters: ProductFilterInput?
}
