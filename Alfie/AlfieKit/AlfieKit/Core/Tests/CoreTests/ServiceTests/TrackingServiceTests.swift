import CommonTestUtils
import Core
import Mocks
import XCTest

final class TrackingServiceTests: XCTestCase {
    private var sut: TrackingService!
    private var trackingProvider: MockTrackingProvider!

    override func setUp() {
        super.setUp()
        trackingProvider = .init()
        sut = .init(providers: [trackingProvider])
    }

    override func tearDown() {
        sut = nil
        trackingProvider = nil
        super.tearDown()
    }

    func test_enableAllProviders_callEnabledMethodInProvider() {
        let expectation = expectation(description: "enableAllProviders_callEnabledMethodInProvider")
        trackingProvider.onEnableCalled = {
            expectation.fulfill()
        }

        sut.enableAllProviders()

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_disableAllProviders_callDisableMethodInProvider() {
        let expectation = expectation(description: "disableAllProviders_callDisableMethodInProvider")
        trackingProvider.onDisableCalled = {
            expectation.fulfill()
        }

        sut.disableAllProviders()

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_trackEvent_ProviderEnabled_callTrackMethodInProvider() {
        let expectation = expectation(description: "trackEvent_ProviderEnabled_callTrackMethodInProvider")
        let expectedName = "Test"
        trackingProvider.onTrackEventCalled = { name, parameters in
            XCTAssertEqual(name, expectedName)
            expectation.fulfill()
        }

        trackingProvider.isEnabled = true
        sut.track(name: expectedName, parameters: nil)

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_trackEvent_ProviderDisabled_doesNOTcallTrackMethodInProvider() {
        let expectation = expectation(description: "trackEvent_ProviderEnabled_callTrackMethodInProvider")
        expectation.isInverted = true
        let expectedName = "Test"
        trackingProvider.onTrackEventCalled = { name, parameters in
            XCTAssertEqual(name, expectedName)
            expectation.fulfill()
        }

        trackingProvider.isEnabled = false
        sut.track(name: expectedName, parameters: nil)

        waitForExpectations(timeout: defaultTimeout)
    }
}
