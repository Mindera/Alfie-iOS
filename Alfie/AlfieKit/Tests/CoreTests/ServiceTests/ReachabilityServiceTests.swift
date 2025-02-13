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
            XCTAssertEqual(queue.label, self.testQueue.label, "Monitor should use the injected queue")
            expectation.fulfill()
        }

        sut = ReachabilityService(monitor: mockMonitor, monitorQueue: testQueue)
        wait(for: [expectation], timeout: timeout)
    }

    func test_reachabilityService_publishesNetworkAvailabilityUpdates() {
        let resultUnavailable = captureEvent(
            fromPublisher: sut.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockMonitor.simulateNetworkAvailability(available: false) }
        )

        XCTAssertEqual(resultUnavailable, false)

        let resultAvailable = captureEvent(
            fromPublisher: sut.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockMonitor.simulateNetworkAvailability(available: true) }
        )

        XCTAssertEqual(resultAvailable, true)
    }

    func test_reachabilityService_storesCurrentNetworkAvailability() {
       captureEvent(
            fromPublisher: sut.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockMonitor.simulateNetworkAvailability(available: false) }
        )

        XCTAssertFalse(sut.isNetworkAvailable)

        captureEvent(
            fromPublisher: sut.networkAvailability.eraseToAnyPublisher(),
            afterTrigger: { mockMonitor.simulateNetworkAvailability(available: true) }
        )

        XCTAssertTrue(sut.isNetworkAvailable)
    }
}
