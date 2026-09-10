import Combine
import Mocks
import Model
import XCTest
@testable import Core

/// What the service reports when there is no camera to give the ViewModel.
///
/// The device capability check and the authorisation prompt are injected, because the two facts
/// worth asserting here are about *whether they were consulted at all* — a simulator can neither
/// support live data scanning nor be asked twice about a camera it does not have. The success path
/// is not covered: it ends inside `DataScannerViewController`, which needs a real camera.
final class CameraScanServiceTests: XCTestCase {
    private var accessRequestCount = 0
    private var failures: [CameraScanFailure] = []
    private var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        accessRequestCount = 0
        failures = []
        subscriptions = []
    }

    /// Asking for a camera we have no use for is a prompt the shopper has to answer for nothing, and
    /// a permission they have then granted to an app that still cannot scan.
    @MainActor
    func test_aDeviceThatCannotScanIsNeverAskedForTheCamera() async {
        let sut = makeSut(isDeviceSupported: false, isAccessGranted: true)

        sut.startScanning()
        await settle(until: { self.failures.count == 1 })

        XCTAssertEqual(accessRequestCount, 0)
        XCTAssertEqual(failures, [.deviceNotSupported])
    }

    @MainActor
    func test_aRefusedCameraIsReportedAsRefused() async {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)

        sut.startScanning()
        await settle(until: { self.failures.count == 1 })

        XCTAssertEqual(accessRequestCount, 1)
        XCTAssertEqual(failures, [.permissionDenied])
    }

    /// A refusal leaves nothing scanning and nobody having asked it to stop, so the next appearance
    /// has to reach the camera again — the shopper may have granted access in Settings meanwhile.
    @MainActor
    func test_aRefusedCameraIsAskedAgainOnTheNextStart() async {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)

        sut.startScanning()
        await settle(until: { self.failures.count == 1 })
        sut.startScanning()
        await settle(until: { self.failures.count == 2 })

        XCTAssertEqual(accessRequestCount, 2)
        XCTAssertEqual(failures, [.permissionDenied, .permissionDenied])
    }

    /// Stopping before the prompt is answered abandons that start request: the screen has gone, so
    /// nothing should be reported about a camera nobody is looking at any more.
    @MainActor
    func test_aStartAbandonedBeforeTheAnswerReportsNothing() async {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)

        sut.startScanning()
        sut.stopScanning()
        // Waits for the prompt to have been answered, which is the point at which an abandoned start
        // would report if it were going to. Waiting for a failure instead would mean waiting for
        // something that must never arrive, which can only ever be a timeout.
        await settle(until: { self.accessRequestCount == 1 })

        XCTAssertTrue(failures.isEmpty)
    }

    /// The last of the three ways a start can end without a camera, and the only one that is not
    /// visible before the prompt: the device can scan and the shopper has said yes, but the scanner
    /// itself will not run. Left unstubbed this is unreachable — the real check is false on every
    /// simulator, so it would mask the two cases above rather than be tested by them.
    @MainActor
    func test_aScannerThatWillNotRunIsReportedAsUnavailable() async {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: true, isScanningAvailable: false)

        sut.startScanning()
        await settle(until: { self.failures.count == 1 })

        XCTAssertEqual(accessRequestCount, 1)
        XCTAssertEqual(failures, [.unavailable])
    }

    // MARK: - Helpers

    @MainActor
    private func makeSut(
        isDeviceSupported: Bool,
        isAccessGranted: Bool,
        isScanningAvailable: Bool = true
    ) -> CameraScanService {
        let sut = CameraScanService(
            log: MockLogger(),
            isDeviceSupported: { isDeviceSupported },
            // Stubbed rather than left to the real check, which is false on a simulator: most of
            // these cases are about the checks that come before it, and the real one would mask them.
            isScanningAvailable: { isScanningAvailable },
            requestCameraAccess: { [weak self] in
                self?.accessRequestCount += 1
                return isAccessGranted
            }
        )
        sut.failurePublisher
            .sink { [weak self] in self?.failures.append($0) }
            .store(in: &subscriptions)
        return sut
    }

    /// Lets the service's authorisation `Task` reach the outcome the caller is waiting for.
    ///
    /// Keyed on that outcome rather than on a count of hops: how many awaits the implementation
    /// happens to contain is not something a test should have to know, and a fixed count stops being
    /// enough the moment one is added — silently, as a pass. It yields rather than sleeping, so the
    /// deadline is a backstop against a hang, not a delay any passing run waits out.
    private func settle(until isSatisfied: () -> Bool, timeout: TimeInterval = 1) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !isSatisfied(), Date() < deadline {
            await Task.yield()
        }
        // One more hop, so that a continuation released by the last one has run before the
        // assertions read what it did.
        await Task.yield()
    }
}
