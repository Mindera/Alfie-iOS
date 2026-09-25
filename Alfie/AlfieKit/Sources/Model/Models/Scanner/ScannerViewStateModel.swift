import Foundation

/// What the scanner screen shows while the camera is running.
///
/// The notice is part of the same state as the guidance rather than a channel of its own, because
/// the two occupy the screen together: a shopper who has just scanned the wrong thing needs to be
/// told so *and* told what to point at instead.
public struct ScannerViewStateModel: Equatable {
    /// What to point the camera at. Always present.
    public let guidance: String
    /// What the last recognised code prompted, or `nil` when there is nothing to say. Shown without
    /// closing the camera: a notice is a correction, not a dead end.
    public let notice: ScannerNotice?
    public let isRecognised: Bool
    public let isLookingUp: Bool

    public init(guidance: String, notice: ScannerNotice? = nil, isRecognised: Bool = false, isLookingUp: Bool = false) {
        self.guidance = guidance
        self.notice = notice
        self.isRecognised = isRecognised
        self.isLookingUp = isLookingUp
    }

    public func with(notice: ScannerNotice?) -> Self {
        .init(guidance: guidance, notice: notice, isRecognised: isRecognised, isLookingUp: isLookingUp)
    }

    /// A lookup is in flight, and supersedes whatever the last scan had to say — so the notice goes.
    public func lookingUp() -> Self {
        .init(guidance: guidance, notice: nil, isRecognised: isRecognised, isLookingUp: true)
    }

    /// The lookup is over. Any notice stays: a lookup that found nothing ends by saying so.
    public func lookupFinished() -> Self {
        .init(guidance: guidance, notice: notice, isRecognised: isRecognised, isLookingUp: false)
    }

    /// A code the app can act on. Nothing is left to correct and no lookup is outstanding.
    public func recognised() -> Self {
        .init(guidance: guidance, notice: nil, isRecognised: true)
    }
}
