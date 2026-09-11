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

    // The menu is hardcoded for the demo, so these assert the fixed list rather than a BFF call.
    // Restore an `onGetHeaderNavCalled` expectation here when the service goes back to the real menu.
    func test_get_navigation_items_returns_hardcoded_categories() async throws {
        let items = try await sut.getNavigationItems(for: .shop)

        XCTAssertEqual(items.map(\.id), ["women-1", "men-2", "shoes-76", "sale-23"])
        XCTAssertEqual(items.map(\.title), ["Women", "Men", "Shoes", "Sale"])
        XCTAssertEqual(items.map(\.url), ["/women-1", "/men-2", "/shoes-76", "/sale-23"])
        XCTAssertTrue(items.allSatisfy { $0.type == .listing })
    }

    func test_get_navigation_items_does_not_call_bff_service() async throws {
        var didCallBFF = false
        mockClientService.onGetHeaderNavCalled = { _ in
            didCallBFF = true
            return []
        }

        _ = try await sut.getNavigationItems(for: .shop)

        XCTAssertFalse(didCallBFF)
    }
}
