import AVFoundation
import Combine
import Mocks
import Model
import TestUtils
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

    override func tearDownWithError() throws {
        subscriptions = []
        failures = []
        accessRequestCount = 0
        try super.tearDownWithError()
    }

    /// Asking for a camera we have no use for is a prompt the shopper has to answer for nothing, and
    /// a permission they have then granted to an app that still cannot scan.
    @MainActor
    func test_start_on_unsupported_device_reports_unsupported_without_asking_for_camera() {
        let sut = makeSut(isDeviceSupported: false, isAccessGranted: true)

        XCTAssertEmitsValue(from: sut.failurePublisher, afterTrigger: sut.startScanning)

        XCTAssertEqual(accessRequestCount, 0)
        XCTAssertEqual(failures, [.deviceNotSupported])
    }

    @MainActor
    func test_start_with_camera_refused_reports_permission_denied() {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)

        XCTAssertEmitsValue(from: sut.failurePublisher, afterTrigger: sut.startScanning)

        XCTAssertEqual(accessRequestCount, 1)
        XCTAssertEqual(failures, [.permissionDenied])
    }

    /// A refusal leaves nothing scanning and nobody having asked it to stop, so the next appearance
    /// has to reach the camera again — the shopper may have granted access in Settings meanwhile.
    @MainActor
    func test_start_after_refusal_asks_for_camera_again() {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: false)
        XCTAssertEmitsValue(from: sut.failurePublisher, afterTrigger: sut.startScanning)

        XCTAssertEmitsValue(from: sut.failurePublisher, afterTrigger: sut.startScanning)

        XCTAssertEqual(accessRequestCount, 2)
        XCTAssertEqual(failures, [.permissionDenied, .permissionDenied])
    }

    /// Stopping before the prompt is answered abandons that start request: the screen has gone, so
    /// nothing should be reported about a camera nobody is looking at any more.
    @MainActor
    func test_stop_before_prompt_is_answered_reports_nothing() async {
        let prompt = CameraAccessPrompt()
        let promptRaised = expectation(description: "camera access prompt raised")
        let promptAnswered = expectation(description: "camera access prompt answered")
        let sut = makeSut(isDeviceSupported: true) {
            let isGranted = await prompt.ask(raised: promptRaised)
            promptAnswered.fulfill()
            return isGranted
        }
        sut.startScanning()
        await fulfillment(of: [promptRaised], timeout: .default)

        sut.stopScanning()

        await prompt.answer(isGranted: false)
        // The service resumes from the prompt in the same main-actor job that fulfils this, so an
        // abandoned start that were going to report would already have done so.
        await fulfillment(of: [promptAnswered], timeout: .default)
        XCTAssertEqual(accessRequestCount, 1)
        XCTAssertTrue(failures.isEmpty)
    }

    /// The last of the three ways a start can end without a camera, and the only one that is not
    /// visible before the prompt: the device can scan and the shopper has said yes, but the scanner
    /// itself will not run. Left unstubbed this is unreachable — the real check is false on every
    /// simulator, so it would mask the two cases above rather than be tested by them.
    @MainActor
    func test_start_with_scanner_unavailable_reports_unavailable() {
        let sut = makeSut(isDeviceSupported: true, isAccessGranted: true, isScanningAvailable: false)

        XCTAssertEmitsValue(from: sut.failurePublisher, afterTrigger: sut.startScanning)

        XCTAssertEqual(accessRequestCount, 1)
        XCTAssertEqual(failures, [.unavailable])
    }

    // MARK: - Camera access explainer

    @MainActor
    func test_can_ask_for_camera_access_only_before_ios_has_asked() {
        let cases: [(status: AVAuthorizationStatus, isAccessGranted: Bool, expected: Bool)] = [
            (.notDetermined, false, true),
            (.denied, false, false),
            (.authorized, true, false),
        ]

        for (status, isAccessGranted, expected) in cases {
            let sut = makeSut(isDeviceSupported: true, isAccessGranted: isAccessGranted, status: status)

            let canAsk = sut.canAskForCameraAccess

            XCTAssertEqual(canAsk, expected, "Unexpected answer for authorisation status \(status.rawValue)")
        }
    }

    @MainActor
    func test_can_ask_for_camera_access_on_unsupported_device_is_false() {
        let sut = makeSut(isDeviceSupported: false, isAccessGranted: false, status: .notDetermined)

        let canAsk = sut.canAskForCameraAccess

        XCTAssertFalse(canAsk)
    }

    // MARK: - Helpers

    @MainActor
    private func makeSut(
        isDeviceSupported: Bool,
        isAccessGranted: Bool,
        isScanningAvailable: Bool = true,
        status: AVAuthorizationStatus = .notDetermined
    ) -> CameraScanService {
        makeSut(
            isDeviceSupported: isDeviceSupported,
            isScanningAvailable: isScanningAvailable,
            status: status,
            requestCameraAccess: { isAccessGranted }
        )
    }

    @MainActor
    private func makeSut(
        isDeviceSupported: Bool,
        isScanningAvailable: Bool = true,
        status: AVAuthorizationStatus = .notDetermined,
        requestCameraAccess: @escaping @MainActor () async -> Bool
    ) -> CameraScanService {
        let sut = CameraScanService(
            log: MockLogger(),
            isDeviceSupported: { isDeviceSupported },
            // Stubbed rather than left to the real check, which is false on a simulator: most of
            // these cases are about the checks that come before it, and the real one would mask them.
            isScanningAvailable: { isScanningAvailable },
            requestCameraAccess: { [weak self] in
                self?.accessRequestCount += 1
                return await requestCameraAccess()
            },
            cameraAuthorizationStatus: { status }
        )
        sut.failurePublisher
            .sink { [weak self] in self?.failures.append($0) }
            .store(in: &subscriptions)
        return sut
    }
}

/// Holds the system camera prompt open until the test answers it, so a stop can land while the
/// shopper is still looking at the alert.
private actor CameraAccessPrompt {
    private var continuation: CheckedContinuation<Bool, Never>?

    func ask(raised: XCTestExpectation) async -> Bool {
        raised.fulfill()
        return await withCheckedContinuation { continuation = $0 }
    }

    func answer(isGranted: Bool) {
        continuation?.resume(returning: isGranted)
        continuation = nil
    }
}
