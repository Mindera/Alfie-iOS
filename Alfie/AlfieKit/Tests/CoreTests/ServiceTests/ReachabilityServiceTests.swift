import Mocks
import XCTest
@testable import Core

final class ReachabilityServiceTests: XCTestCase {
    private var mockReachabilityService: MockReachabilityService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockReachabilityService = MockReachabilityService()
    }

    override func tearDownWithError() throws {
        mockReachabilityService = nil
        try super.tearDownWithError()
    }

    func test_reachabilityService_publishesNetworkAvailabilityUpdates() {
        let resultUnavailable = captureEvent(
            fromPublisher: mockReachabilityService.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockReachabilityService.simulateNetworkAvailability(available: false) }
        )

        XCTAssertEqual(resultUnavailable, false)

        let resultAvailable = captureEvent(
            fromPublisher: mockReachabilityService.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockReachabilityService.simulateNetworkAvailability(available: true) }
        )

        XCTAssertEqual(resultAvailable, true)
    }

    func test_reachabilityService_storesCurrentNetworkAvailability() {
       captureEvent(
            fromPublisher: mockReachabilityService.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockReachabilityService.simulateNetworkAvailability(available: false) }
        )

        XCTAssertFalse(mockReachabilityService.isNetworkAvailable)

        captureEvent(
            fromPublisher: mockReachabilityService.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockReachabilityService.simulateNetworkAvailability(available: true) }
        )

        XCTAssertTrue(mockReachabilityService.isNetworkAvailable)
    }
}
