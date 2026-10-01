import Foundation

/// Why the camera is not recognising anything.
///
/// Reported by ``CameraScanServiceProtocol`` in place of the recognitions a start request was
/// expected to produce. Kept separate from ``ScannerViewErrorType`` so the service describes the
/// camera it found and the ViewModel decides what a shopper is told about it.
public enum CameraScanFailure: Equatable {
    /// This device cannot do live data scanning. Known before the camera is touched, so a device
    /// that cannot scan never raises the permission prompt.
    case deviceNotSupported
    /// Camera access was refused — at the prompt, or later in Settings.
    case permissionDenied
    /// The camera is supported and permitted, but the session would not start: another app holds
    /// it, the device is locked, or Screen Time restricts it.
    case unavailable
}
