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
        for row in BFFFailureRow.all {
            makeSUT()
            mockBFFClient.onGetProductCalled = { _ in throw row.error }
            mockBFFClient.onRelatedProductsCalled = { _, _ in [] }

            appearAndWaitForBothRequests()

            XCTAssertEqual(sut.state.failure, row.pdp, row.name)
        }
    }

    func test_related_products_failure_from_the_bff_client_stays_silent() {
        for row in BFFFailureRow.all {
            makeSUT()
            mockBFFClient.onGetProductCalled = { _ in .fixture() }
            mockBFFClient.onRelatedProductsCalled = { _, _ in throw row.error }

            appearAndWaitForBothRequests()

            XCTAssertTrue(sut.state.isSuccess, row.name)
            XCTAssertFalse(sut.shouldShow(section: .relatedProducts), row.name)
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
