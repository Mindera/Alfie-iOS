import Mocks
import Model
import TestUtils
import XCTest
@testable import ProductDetails

final class ProductDetailsRetryTests: XCTestCase {
    private var sut: ProductDetailsViewModel!
    private var mockBFFClient: MockBFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockBFFClient = MockBFFClientService()
        sut = .onRealServices(bffClient: mockBFFClient)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockBFFClient = nil
        try super.tearDownWithError()
    }

    func test_retry_shows_the_loading_skeleton_while_the_product_reloads() {
        arrangeAppearedScreen(
            productResponse: { _ in throw BFFRequestError(type: .generic) },
            relatedProductsResponse: { _, _ in [] }
        )

        sut.didTapRetry()

        XCTAssertTrue(sut.state.isLoading)
        XCTAssertTrue(sut.relatedProductsState.isLoading)
    }

    func test_retry_after_a_failure_reloads_the_product_and_related_products_to_success() {
        arrangeAppearedScreen(
            productResponse: { _ in throw BFFRequestError(type: .generic) },
            relatedProductsResponse: { _, _ in throw BFFRequestError(type: .generic) }
        )
        mockBFFClient.onGetProductCalled = { _ in .fixture(name: "Reloaded") }
        mockBFFClient.onRelatedProductsCalled = { _, _ in [.fixture(id: "related", slug: "other")] }

        XCTAssertEmitsValue(
            from: sut.$state.combineLatest(sut.$relatedProductsState),
            where: { !$0.isLoading && !$1.isLoading },
            afterTrigger: { self.sut.didTapRetry() }
        )

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.productName, "Reloaded")
        XCTAssertEqual(sut.relatedProducts.map(\.id), ["related"])
    }

    func test_retry_that_fails_again_ends_in_the_error_state() {
        arrangeAppearedScreen(
            productResponse: { _ in throw BFFRequestError(type: .generic) },
            relatedProductsResponse: { _, _ in [] }
        )
        mockBFFClient.onGetProductCalled = { _ in throw BFFRequestError(type: .emptyResponse) }

        XCTAssertEmitsValue(
            from: sut.$state.combineLatest(sut.$relatedProductsState),
            where: { !$0.isLoading && !$1.isLoading },
            afterTrigger: { self.sut.didTapRetry() }
        )

        XCTAssertEqual(sut.state.failure, .notFound)
    }

    func test_tapping_retry_again_while_the_retry_loads_does_not_load_twice() {
        arrangeAppearedScreen(
            productResponse: { _ in throw BFFRequestError(type: .generic) },
            relatedProductsResponse: { _, _ in [] }
        )
        let secondProductLoad = expectation(description: "Product is not loaded twice")
        secondProductLoad.isInverted = true
        let secondRelatedLoad = expectation(description: "Related products are not loaded twice")
        secondRelatedLoad.isInverted = true
        var productLoads = 0
        var relatedLoads = 0
        mockBFFClient.onGetProductCalled = { _ in
            productLoads += 1
            if productLoads > 1 { secondProductLoad.fulfill() }
            return .fixture()
        }
        mockBFFClient.onRelatedProductsCalled = { _, _ in
            relatedLoads += 1
            if relatedLoads > 1 { secondRelatedLoad.fulfill() }
            return []
        }

        XCTAssertEmitsValue(
            from: sut.$state.combineLatest(sut.$relatedProductsState),
            where: { !$0.isLoading && !$1.isLoading },
            afterTrigger: {
                self.sut.didTapRetry()
                self.sut.didTapRetry()
            }
        )

        wait(for: [secondProductLoad, secondRelatedLoad], timeout: .inverted)
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_retry_while_related_products_are_still_loading_does_not_request_them_again() async {
        mockBFFClient.onGetProductCalled = { _ in throw BFFRequestError(type: .generic) }
        let gate = ResponseGate()
        let relatedRequested = expectation(description: "Related products are requested")
        let secondRelatedRequest = expectation(description: "Related products are not requested again")
        secondRelatedRequest.isInverted = true
        var relatedRequests = 0
        mockBFFClient.onRelatedProductsCalled = { _, _ in
            relatedRequests += 1
            if relatedRequests > 1 { secondRelatedRequest.fulfill() }
            await gate.hold(signal: relatedRequested)
            return []
        }
        XCTAssertEmitsValue(from: sut.$state, where: { $0.didFail }, afterTrigger: { self.sut.viewDidAppear() })
        await fulfillment(of: [relatedRequested], timeout: .default)

        sut.didTapRetry()

        await fulfillment(of: [secondRelatedRequest], timeout: .inverted)
        await gate.open()
    }

    private func arrangeAppearedScreen(
        productResponse: @escaping (String) async throws -> Product,
        relatedProductsResponse: @escaping (String, Int) async throws -> [Product]
    ) {
        mockBFFClient.onGetProductCalled = productResponse
        mockBFFClient.onRelatedProductsCalled = relatedProductsResponse
        XCTAssertEmitsValue(
            from: sut.$state.combineLatest(sut.$relatedProductsState),
            where: { !$0.isLoading && !$1.isLoading },
            afterTrigger: { self.sut.viewDidAppear() }
        )
    }
}
