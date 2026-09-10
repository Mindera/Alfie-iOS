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
        await settle()

        XCTAssertEqual(accessRequestCount, 0)
        XCTAssertEqual(failures, [.deviceNotSupported])
    }

    @MainActor
    func test_aRefusedCameraIsReportedAsRefused() async {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)

        sut.startScanning()
        await settle()

        XCTAssertEqual(accessRequestCount, 1)
        XCTAssertEqual(failures, [.permissionDenied])
    }

    /// A refusal leaves nothing scanning and nobody having asked it to stop, so the next appearance
    /// has to reach the camera again — the shopper may have granted access in Settings meanwhile.
    @MainActor
    func test_aRefusedCameraIsAskedAgainOnTheNextStart() async {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)

        sut.startScanning()
        await settle()
        sut.startScanning()
        await settle()

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
        await settle()

        XCTAssertTrue(failures.isEmpty)
    }

    // MARK: - Helpers

    @MainActor
    private func makeSut(isDeviceSupported: Bool, isAccessGranted: Bool) -> CameraScanService {
        let sut = CameraScanService(
            log: MockLogger(),
            isDeviceSupported: { isDeviceSupported },
            // Stubbed rather than left to the real check, which is false on a simulator: these cases
            // are about the checks that come before it, and the real one would mask them.
            isScanningAvailable: { true },
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

    /// Lets the service's authorisation `Task` run to completion. It hops the main actor rather than
    /// waiting on a clock, so a yield is enough and there is no sleep to make this flaky.
    private func settle() async {
        for _ in 0..<10 {
            await Task.yield()
        }
    }
}
