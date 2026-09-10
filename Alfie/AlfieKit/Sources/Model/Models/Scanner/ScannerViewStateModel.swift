import Foundation

/// What the scanner screen shows while the camera is running.
///
/// The notice is part of the same state as the guidance rather than a channel of its own, because
/// the two occupy the screen together: a shopper who has just scanned the wrong thing needs to be
/// told so *and* told what to point at instead.
public struct ScannerViewStateModel: Equatable {
    /// What to point the camera at. Always present.
    public let guidance: String
    /// A message about the last code recognised, or `nil` when there is nothing to say. Shown
    /// without closing the camera: a notice is a correction, not a dead end.
    public let notice: String?

    public init(guidance: String, notice: String? = nil) {
        self.guidance = guidance
        self.notice = notice
    }

    public func with(notice: String?) -> Self {
        .init(guidance: guidance, notice: notice)
    }
}
