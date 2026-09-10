import Foundation

/// Why a scan did not produce a Product, in the vocabulary the `scan_failed` analytics event uses.
///
/// A type rather than a bare string so the reasons stay a closed set: they are read as a breakdown,
/// and a typo would quietly split one bar into two.
public enum ScanFailureReason: String {
    /// A code was read, and it was not an Alfie code.
    case unrecognised
    /// The shopper has refused camera access, or it is switched off in Settings.
    case permissionDenied = "permission_denied"
    /// The device cannot do live data scanning.
    case unsupported
    /// The camera exists and is permitted, but the session would not start.
    case generic
}
