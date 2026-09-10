import Foundation

/// Why the scanner cannot show a camera at all.
///
/// Distinct from a notice: a notice is shown *over* a running camera and the shopper can try again
/// straight away, whereas each of these replaces the preview, because there is nothing to preview.
public enum ScannerViewErrorType: Error, Equatable, CaseIterable {
    /// The shopper has refused camera access, or it is switched off in Settings. Recoverable, and
    /// the only case that offers a way out of the screen other than closing it.
    case cameraPermissionDenied
    /// The device cannot do live data scanning. Nothing the shopper can do about it.
    case deviceNotSupported
    /// The camera exists and is permitted, but the session would not start.
    case generic

    public static func from(_ failure: CameraScanFailure) -> Self {
        switch failure {
        case .permissionDenied: return .cameraPermissionDenied
        case .deviceNotSupported: return .deviceNotSupported
        case .unavailable: return .generic
        }
    }
}
