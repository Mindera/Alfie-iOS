import Mocks
import Model
import TestUtils
import XCTest
@testable import ProductDetails

final class ProductDetailsViewModelFailureKindTests: XCTestCase {
    private var sut: ProductDetailsViewModel!
    private var mockBFFClient: MockBFFClientService!

    override func tearDownWithError() throws {
        sut = nil
        mockBFFClient = nil
        try super.tearDownWithError()
    }

    func test_product_failure_from_the_bff_client_reaches_the_screen_as_its_failure_kind() {
        let cases: [(BFFRequestError.BFFRequestErrorType, ProductDetailsViewErrorType)] = [
            (.serverError(status: 503), .serverError),
            (.rateLimited(retryAfter: 30), .rateLimited),
            (.noInternet, .noConnection),
            (.timeout, .generic),
            (.generic, .generic),
            (.emptyResponse, .notFound),
            (.product(.noProduct), .notFound),
        ]

        for (bffError, expected) in cases {
            makeSUT()
            mockBFFClient.onGetProductCalled = { _ in throw BFFRequestError(type: bffError) }
            mockBFFClient.onRelatedProductsCalled = { _, _ in [] }

            appearAndWaitForBothRequests()

            XCTAssertEqual(sut.state.failure, expected, "for \(bffError)")
        }
    }

    func test_related_products_failure_from_the_bff_client_stays_silent() {
        let failures: [BFFRequestError.BFFRequestErrorType] = [
            .serverError(status: 503),
            .rateLimited(retryAfter: 30),
            .noInternet,
        ]

        for bffError in failures {
            makeSUT()
            mockBFFClient.onGetProductCalled = { _ in .fixture() }
            mockBFFClient.onRelatedProductsCalled = { _, _ in throw BFFRequestError(type: bffError) }

            appearAndWaitForBothRequests()

            XCTAssertTrue(sut.state.isSuccess, "for \(bffError)")
            XCTAssertFalse(sut.shouldShow(section: .relatedProducts), "for \(bffError)")
        }
    }

    private func makeSUT() {
        mockBFFClient = MockBFFClientService()
        sut = .onRealServices(bffClient: mockBFFClient)
    }

    private func appearAndWaitForBothRequests() {
        XCTAssertEmitsValue(
            from: sut.$state.combineLatest(sut.$relatedProductsState),
            where: { !$0.isLoading && !$1.isLoading },
            afterTrigger: { self.sut.viewDidAppear() }
        )
    }
}
