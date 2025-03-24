import Mocks
import XCTest
@testable import Core

final class ReachabilityServiceTests: XCTestCase {
    private var mockMonitor: MockNetworkPathMonitor!
    private var sut: ReachabilityService!
    private var testQueue: DispatchQueue!
    private var timeout: CGFloat!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMonitor = MockNetworkPathMonitor()
        testQueue = DispatchQueue(label: "test.queue", qos: .utility)
        sut = ReachabilityService(monitor: mockMonitor, monitorQueue: testQueue)
        timeout = 5.0
    }

    override func tearDownWithError() throws {
        mockMonitor = nil
        testQueue = nil
        sut = nil
        timeout = nil
        try super.tearDownWithError()
    }

    func test_reachabilityService_startsMonitorOnInit() {
        let expectation = expectation(description: "Wait for monitor start")

        mockMonitor.onStartMonitoringCalled = { _ in
            expectation.fulfill()
        }

        sut = ReachabilityService(monitor: mockMonitor, monitorQueue: testQueue)
        wait(for: [expectation], timeout: timeout)
    }

    func test_reachabilityService_stopsMonitorOnDeinit() {
        let expectation = expectation(description: "Wait for monitor stop")

        mockMonitor.onStopMonitoringCalled = {
            expectation.fulfill()
        }

        sut = nil
        wait(for: [expectation], timeout: timeout)
    }

    func test_reachabilityService_usesInjectedQueueForMonitoring() {
        let expectation = expectation(description: "Wait for queue verification")

        mockMonitor.onStartMonitoringCalled = { queue in
            XCTAssertTrue(queue === self.testQueue, "Monitor should use the injected queue")
            expectation.fulfill()
        }

        sut = ReachabilityService(monitor: mockMonitor, monitorQueue: testQueue)
        wait(for: [expectation], timeout: timeout)
    }

    func test_reachabilityService_publishesNetworkAvailabilityUpdates() {
        // Initialize `isAvailable` to `true` to ensure the event triggers, as repeated events are filtered out.
        mockMonitor.isAvailable = true

        XCTAssertEmitsValueEqualTo(
            from: sut.networkAvailability,
            expectedValue: false,
            afterTrigger: { self.mockMonitor.isAvailable = false }
        )

        XCTAssertEmitsValueEqualTo(
            from: sut.networkAvailability,
            expectedValue: true,
            afterTrigger: { self.mockMonitor.isAvailable = true }
        )
    }

    func test_reachabilityService_storesCurrentNetworkAvailability() {
        // Initialize `isAvailable` to `true` to ensure the event triggers, as repeated events are filtered out.
        mockMonitor.isAvailable = true

        XCTAssertEmitsValue(from: sut.networkAvailability, afterTrigger: { self.mockMonitor.isAvailable = false })

        XCTAssertFalse(sut.isNetworkAvailable)

        XCTAssertEmitsValue(from: sut.networkAvailability, afterTrigger: { self.mockMonitor.isAvailable = true })

        XCTAssertTrue(sut.isNetworkAvailable)
    }
}
