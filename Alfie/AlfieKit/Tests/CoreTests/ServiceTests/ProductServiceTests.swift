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

    // MARK: - Product List

    func test_productList_maps_emptyResponse_to_noProducts() async {
        mockClientService.onProductListCalled = { _, _, _, _, _ in
            throw BFFRequestError(type: .emptyResponse)
        }

        do {
            _ = try await sut.productList(collectionHandle: "c", after: nil, limit: 1, sort: nil, filters: nil)
            XCTFail("Expected productList to throw")
        } catch let error as BFFRequestError {
            guard case .product(.noProducts) = error.type else {
                XCTFail("Expected .product(.noProducts), got \(error.type)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_productList_maps_other_bff_errors_to_generic_product_error() async {
        mockClientService.onProductListCalled = { _, _, _, _, _ in
            throw BFFRequestError(type: .generic)
        }

        do {
            _ = try await sut.productList(collectionHandle: "c", after: nil, limit: 1, sort: nil, filters: nil)
            XCTFail("Expected productList to throw")
        } catch let error as BFFRequestError {
            XCTAssertEqual(error.type, .product(.generic))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_productList_calls_bff_service() async throws {
        var captured: ProductListCall?
        mockClientService.onProductListCalled = { collectionHandle, after, limit, sort, filters in
            captured = ProductListCall(collectionHandle: collectionHandle, after: after, limit: limit, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"])

        _ = try await sut.productList(
            collectionHandle: "category id",
            after: "cursor-1",
            limit: 2,
            sort: "sort",
            filters: filters
        )

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.collectionHandle, "category id")
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, 2)
        XCTAssertEqual(call.sort, "sort")
        XCTAssertEqual(call.filters, filters)
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
