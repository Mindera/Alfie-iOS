@testable import Core
import Mocks
import Models
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

    func test_get_product_calls_bff_service() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onGetProductCalled = { productId in
            XCTAssertEqual(productId, "id")
            expectation.fulfill()
            return Product.fixture()
        }

        Task {
            _ = try await sut.getProduct(id: "id")
        }
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_get_product_throws_no_product_error_when_not_found() {
        mockClientService.onGetProductCalled = { _ in
            throw BFFRequestError.init(type: .emptyResponse)
        }

        let expectation = self.expectation(description: "Wait for error")
        Task {
            do {
                _ = try await sut.getProduct(id: "id")
            } catch {
                XCTAssertEqual((error as? BFFRequestError)?.type, .product(.noProduct))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_get_product_throws_generic_error_when_bff_service_fails() {
        mockClientService.onGetProductCalled = { _ in
            throw BFFRequestError.init(type: .generic)
        }

        let expectation = self.expectation(description: "Wait for error")
        Task {
            do {
                _ = try await sut.getProduct(id: "id")
            } catch {
                XCTAssertEqual((error as? BFFRequestError)?.type, .product(.generic))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: defaultTimeout)
    }

    // MARK: - Get Product List

    func test_get_productList_calls_bff_service() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onProductListingCalled = { offset, limit, categoryId, query, sort in
            XCTAssertEqual(offset, 1)
            XCTAssertEqual(limit, 2)
            XCTAssertEqual(categoryId, "category id")
            XCTAssertEqual(query, "query")
            XCTAssertEqual(sort, "sort")
            expectation.fulfill()
            return ProductListing.fixture()
        }

        Task {
            _ = try await sut.productListing(
                offset: 1,
                limit: 2,
                categoryId: "category id",
                query: "query",
                sort: "sort"
            )
        }
        wait(for: [expectation], timeout: defaultTimeout)
    }
}
