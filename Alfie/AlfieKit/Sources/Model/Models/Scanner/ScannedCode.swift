import Foundation

/// What the scanner made of a code the camera read. Classified by the symbology the camera reported,
/// never by the shape of the payload (ADR-0002).
public enum ScannedCode: Equatable {
    /// A QR code carrying a link the app can open, e.g. `https://localhost:4000/product/<handle>`.
    case alfieCode(URL)
    /// The manufacturer's EAN-13 Barcode, resolved through the catalogue.
    case barcode(value: String)
    /// Anything else the camera recognised: a poster, a colleague's Wi-Fi code, a link that is not
    /// ours.
    case unrecognised(payload: String)

    /// Which of several codes read together the scanner acts on — lower goes first.
    ///
    /// A Swing tag prints the Barcode and the Alfie code side by side, so a camera held over one
    /// routinely sees both. The Alfie code wins: it opens the Product without a catalogue lookup. A
    /// Barcode in turn outranks a code that is not ours at all.
    public var precedence: Int {
        switch self {
        case .alfieCode: return 0
        case .barcode: return 1
        case .unrecognised: return 2
        }
    }
}

public extension Collection where Element == ScannedCode {
    /// The one code from a frame worth acting on, or `nil` when the frame held none.
    ///
    /// Ties keep the order the camera reported, so a frame holding two codes of equal standing
    /// reports the one it saw first rather than an arbitrary pick.
    var codeToActOn: ScannedCode? {
        self.min { $0.precedence < $1.precedence }
    }
}
