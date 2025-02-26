@testable import Core
import Mocks
import XCTest

final class BrandsServiceTests: XCTestCase {
    private var sut: BrandsService!
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

    func test_get_brands_calls_bff_service() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onGetBrandsCalled = {
            expectation.fulfill()
            return []
        }

        Task {
            _ = try await sut.getBrands()
        }

        wait(for: [expectation], timeout: `default`)
    }
}
