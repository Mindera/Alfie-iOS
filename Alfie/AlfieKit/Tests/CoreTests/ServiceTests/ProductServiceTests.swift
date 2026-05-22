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
        var capturedId: String?
        mockClientService.onGetProductCalled = { productId in
            capturedId = productId
            return Product.fixture()
        }

        _ = try await sut.getProduct(id: "id")

        XCTAssertEqual(capturedId, "id")
    }

    func test_get_product_throws_no_product_error_when_not_found() async {
        mockClientService.onGetProductCalled = { _ in
            throw BFFRequestError(type: .emptyResponse)
        }

        do {
            _ = try await sut.getProduct(id: "id")
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
            _ = try await sut.getProduct(id: "id")
            XCTFail("Expected getProduct to throw")
        } catch let error as BFFRequestError {
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Get Product List

    func test_get_productList_calls_bff_service() async throws {
        var captured: ProductListingCall?
        mockClientService.onProductListingCalled = { after, limit, categoryId, query, sort in
            captured = ProductListingCall(after: after, limit: limit, categoryId: categoryId, query: query, sort: sort)
            return ProductListing.fixture()
        }

        _ = try await sut.productListing(
            after: "cursor-1",
            limit: 2,
            categoryId: "category id",
            query: "query",
            sort: "sort"
        )

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, 2)
        XCTAssertEqual(call.categoryId, "category id")
        XCTAssertEqual(call.query, "query")
        XCTAssertEqual(call.sort, "sort")
    }
}

// MARK: - Helpers

private struct ProductListingCall {
    let after: String?
    let limit: Int
    let categoryId: String?
    let query: String?
    let sort: String?
}
