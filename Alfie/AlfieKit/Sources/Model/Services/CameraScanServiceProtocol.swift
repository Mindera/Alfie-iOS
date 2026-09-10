import Combine
import SwiftUI

/// The camera, behind a seam.
///
/// `ScannerViewModel` sees only recognised payload strings and a start/stop switch, so every rule it
/// applies to a scan — which codes open a page, what happens when the same code is seen twice, when
/// recognition may run — is exercised in a unit test on a simulator that has no camera. The real
/// implementation is `CameraScanService`; tests substitute `MockCameraScanService`.
public protocol CameraScanServiceProtocol: AnyObject {
    /// Every code the camera recognises, as the raw string it carries. A QR code emits its contents;
    /// interpreting them is the ViewModel's job, not the camera's.
    var recognisedPayloadPublisher: AnyPublisher<String, Never> { get }

    /// Emitted in place of the recognitions a ``startScanning()`` was expected to produce, when
    /// there turns out to be no camera to produce them. Silence means the camera is running: a
    /// scanner that recognises nothing because it is pointed at a wall is not a failure.
    var failurePublisher: AnyPublisher<CameraScanFailure, Never> { get }

    /// The live preview to put on screen. Returned as a view rather than rendered by `ScannerView`
    /// directly, because only the service knows what it is previewing — a test double shows nothing.
    func makePreview() -> AnyView

    /// Begins recognition, asking for camera access the first time — but only on a device that can
    /// scan, so a device that cannot never raises the prompt. Idempotent: the ViewModel calls it on
    /// every appearance and every return to the foreground.
    func startScanning()

    /// Ends recognition and releases the camera. Idempotent, for the same reason.
    func stopScanning()
}
