import Combine
import TestUtils
import XCTest
@testable import Core
import Mocks
import Model

final class NavigationServiceTests: XCTestCase {
    private var sut: NavigationService!
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

    func test_get_navigation_items_calls_bff_service() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onGetHeaderNavCalled = { handle, includeSubItems, includeMedia in
            XCTAssertEqual(handle, .header)
            XCTAssertTrue(includeSubItems)
            XCTAssertFalse(includeMedia)
            expectation.fulfill()
            return []
        }

        Task {
            _ = try await sut.getNavigationItems(for: .shop, forceRefresh: false)
        }
        wait(for: [expectation], timeout: .default)
    }

    func test_get_navigation_items_forwards_force_refresh_to_bff_service() async throws {
        mockClientService.onGetHeaderNavCalled = { _, _, _ in [] }

        _ = try await sut.getNavigationItems(for: .shop, forceRefresh: true)

        XCTAssertEqual(mockClientService.lastForceRefresh, true)
    }
}
