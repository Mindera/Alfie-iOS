@testable import Core
import Mocks
import Model
import XCTest

final class ProductServiceTests: XCTestCase {
    private var sut: ProductService!
    private var mockClientService: MockBFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
        sut = .init(bffClient: mockClientService)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClientService = nil
        try super.tearDownWithError()
    }

    // MARK: - Get Product

    func test_get_product_calls_bff_service() async throws {
        var capturedHandle: String?
        mockClientService.onGetProductCalled = { handle in
            capturedHandle = handle
            return Product.fixture()
        }

        _ = try await sut.getProduct(handle: "the-handle")

        XCTAssertEqual(capturedHandle, "the-handle")
    }

    func test_get_product_throws_no_product_error_when_not_found() async {
        mockClientService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .emptyResponse)
        }

        do {
            _ = try await sut.getProduct(handle: "the-handle")
            XCTFail("Expected getProduct to throw")
        } catch let error as BFFRequestError {
            XCTAssertEqual(error.type, .product(.noProduct))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_get_product_throws_generic_error_when_bff_service_fails() async {
        mockClientService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        do {
            _ = try await sut.getProduct(handle: "the-handle")
            XCTFail("Expected getProduct to throw")
        } catch let error as BFFRequestError {
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Get Product List

    func test_productListing_maps_emptyResponse_to_noProducts() async {
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in
            throw BFFRequestError(type: .emptyResponse)
        }

        do {
            _ = try await sut.productListing(after: nil, limit: 1, categoryId: "c", query: nil, sort: nil, filters: nil)
            XCTFail("Expected productListing to throw")
        } catch let error as BFFRequestError {
            guard case .product(.noProducts) = error.type else {
                XCTFail("Expected .product(.noProducts), got \(error.type)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_productListing_maps_other_bff_errors_to_generic_product_error() async {
        mockClientService.onProductListingCalled = { _, _, _, _, _, _ in
            throw BFFRequestError(type: .generic)
        }

        do {
            _ = try await sut.productListing(after: nil, limit: 1, categoryId: "c", query: nil, sort: nil, filters: nil)
            XCTFail("Expected productListing to throw")
        } catch let error as BFFRequestError {
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_get_productList_calls_bff_service() async throws {
        var captured: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort, filters in
            captured = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"])

        _ = try await sut.productListing(
            after: "cursor-1",
            limit: 2,
            categoryId: "category id",
            query: "query",
            sort: "sort",
            filters: filters
        )

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, 2)
        XCTAssertEqual(call.categoryId, "category id")
        XCTAssertEqual(call.query, "query")
        XCTAssertEqual(call.sort, "sort")
        XCTAssertEqual(call.filters, filters)
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
