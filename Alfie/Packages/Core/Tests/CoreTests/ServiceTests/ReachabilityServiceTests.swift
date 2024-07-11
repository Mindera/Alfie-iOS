import Mocks
import XCTest
@testable import Core

final class ReachabilityServiceTests: XCTestCase {
    private var sut: ReachabilityService!
    private var mockReachabilityMonitor: MockReachabilityMonitor!
    private var timeout: CGFloat!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockReachabilityMonitor = .init()
        timeout = 5.0
        sut = ReachabilityService(monitor: mockReachabilityMonitor)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockReachabilityMonitor = nil
        timeout = nil
        try super.tearDownWithError()
    }

    func test_reachabilityService_startsMonitorOnInit() {
        sut = nil
        mockReachabilityMonitor = .init()

        let expectation = expectation(description: "Wait for monitor start")
        mockReachabilityMonitor.onStartMonitoringCalled = {
            expectation.fulfill()
        }

        sut = ReachabilityService(monitor: mockReachabilityMonitor)
        wait(for: [expectation], timeout: timeout)
    }

    func test_reachabilityService_stopsMonitorOnDeinit() {
        let expectation = expectation(description: "Wait for monitor stop")
        mockReachabilityMonitor.onStopMonitoringCalled = {
            expectation.fulfill()
        }

        sut = nil
        wait(for: [expectation], timeout: timeout)
    }

    func test_reachabilityService_publishesNetworkAvailabilityUpdates() {
        let resultUnavailable = captureEvent(fromPublisher: sut.networkAvailability.eraseToAnyPublisher(), afterTrigger: {
            mockReachabilityMonitor.simulateNetworkAvailability(available: false)
        })

        XCTAssertEqual(resultUnavailable, false)

        let resultAvailable = captureEvent(fromPublisher: sut.networkAvailability.eraseToAnyPublisher(), afterTrigger: {
            mockReachabilityMonitor.simulateNetworkAvailability(available: true)
        })

        XCTAssertEqual(resultAvailable, true)
    }

    func test_reachabilityService_storesCurrentNetworkAvailability() {
        _ = captureEvent(fromPublisher: sut.networkAvailability.eraseToAnyPublisher(), afterTrigger: {
            mockReachabilityMonitor.simulateNetworkAvailability(available: false)
        })

        XCTAssertFalse(sut.isNetworkAvailable)

        _ = captureEvent(fromPublisher: sut.networkAvailability.eraseToAnyPublisher(), afterTrigger: {
            mockReachabilityMonitor.simulateNetworkAvailability(available: true)
        })

        XCTAssertTrue(sut.isNetworkAvailable)
    }
}
