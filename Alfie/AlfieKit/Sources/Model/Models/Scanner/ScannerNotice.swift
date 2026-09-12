import Foundation

/// Something the scanner has to say about the last code, said without closing the camera.
///
/// It carries an identity as well as its words, because a notice is an *event* rather than a state.
/// A second unrecognised code says exactly what the first one said, and a shopper who cannot see
/// the screen still has to be told the second time — comparing the words alone would swallow the
/// repeat and leave VoiceOver silent at the moment the scan failed again.
public struct ScannerNotice: Equatable, Identifiable {
    /// Tells one notice from the next, including a repeat that reads identically.
    public let id: Int
    public let message: String

    public init(id: Int, message: String) {
        self.id = id
        self.message = message
    }
}
