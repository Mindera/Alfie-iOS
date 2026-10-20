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

    // MARK: - Product by Barcode

    func test_product_by_barcode_returns_the_bff_match() async throws {
        var capturedBarcode: String?
        mockClientService.onProductByBarcodeCalled = { barcode in
            capturedBarcode = barcode
            return BarcodeMatch(handle: "black-wool-coat-8", variantId: "22")
        }

        let match = try await sut.productByBarcode("5901234123457")

        XCTAssertEqual(capturedBarcode, "5901234123457")
        XCTAssertEqual(match, BarcodeMatch(handle: "black-wool-coat-8", variantId: "22"))
    }

    func test_product_by_barcode_with_no_match_returns_nil() async throws {
        mockClientService.onProductByBarcodeCalled = { _ in nil }

        let match = try await sut.productByBarcode("5901234123457")

        XCTAssertNil(match)
    }

    func test_product_by_barcode_passes_bff_errors_through_untouched() async {
        mockClientService.onProductByBarcodeCalled = { _ in throw BFFRequestError.passThroughFixture }

        await assertPassesBFFErrorThroughUntouched {
            _ = try await sut.productByBarcode("5901234123457")
        }
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

    func test_get_product_passes_bff_errors_through_untouched() async {
        mockClientService.onGetProductCalled = { _ in throw BFFRequestError.passThroughFixture }

        await assertPassesBFFErrorThroughUntouched {
            _ = try await sut.getProduct(handle: "the-handle")
        }
    }

    // MARK: - Product List

    func test_product_list_passes_bff_errors_through_untouched() async {
        mockClientService.onProductListCalled = { _, _, _, _, _ in throw BFFRequestError.passThroughFixture }

        await assertPassesBFFErrorThroughUntouched {
            _ = try await sut.productList(collectionHandle: "c", after: nil, limit: 1, sort: nil, filters: nil)
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

    // MARK: - Category Price Range

    func test_category_price_range_passes_bff_errors_through_untouched() async {
        mockClientService.onCategoryPriceRangeCalled = { _ in throw BFFRequestError.passThroughFixture }

        await assertPassesBFFErrorThroughUntouched {
            _ = try await sut.categoryPriceRange(collectionHandle: "c")
        }
    }

    // MARK: - Related Products

    func test_related_products_passes_bff_errors_through_untouched() async {
        mockClientService.onRelatedProductsCalled = { _, _ in throw BFFRequestError.passThroughFixture }

        await assertPassesBFFErrorThroughUntouched {
            _ = try await sut.relatedProducts(handle: "the-handle", limit: 4)
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
