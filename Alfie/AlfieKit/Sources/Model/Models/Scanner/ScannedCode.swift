import Foundation

/// What the scanner made of a code the camera read.
///
/// Three outcomes, because a Swing tag carries two codes and the rest of the world carries a third.
/// Only the first is ever resolved. A Barcode is classified purely so the shopper can be told which
/// code to scan instead — Alfie cannot look a Product up by one, which is the entire reason it
/// prints its own code (ADR-0001) — so nothing is ever fetched for it, and its digits travel no
/// further than the log.
public enum ScannedCode: Equatable {
    /// A code carrying a link the app can open, e.g. `https://localhost:4000/product/<handle>`.
    case alfieCode(URL)
    /// The manufacturer's Barcode. Recognised, never resolved.
    case barcode(value: String)
    /// Anything else the camera recognised: a poster, a colleague's Wi-Fi code, a link that is not
    /// ours.
    case unrecognised(payload: String)

    /// Which of several codes read together the scanner acts on — lower goes first.
    ///
    /// A Swing tag prints the Barcode and the Alfie code side by side, so a camera held over one
    /// routinely sees both. The Alfie code wins: a shopper who scanned correctly must not be
    /// corrected for the Barcode that happened to share the frame, a moment before the Product opens
    /// anyway. A Barcode in turn outranks a code that is not ours at all, because "scan the other
    /// code on this tag" tells the shopper what to do next and "that opens nothing" does not.
    public var precedence: Int {
        switch self {
        case .alfieCode: return 0
        case .barcode: return 1
        case .unrecognised: return 2
        }
    }

    /// Whether a payload is a manufacturer Barcode: thirteen digits whose last is a valid EAN-13
    /// check digit.
    ///
    /// The check digit is tested and not merely the shape, because being wrong here is expensive in
    /// one direction: a QR code holding thirteen digits would be answered with "that's the product
    /// barcode", which is confidently false. Nothing is lost by insisting on it — a camera validates
    /// the check digit before it reports an EAN-13 at all, so every Barcode that reaches this passes.
    ///
    /// UPC-A needs no case of its own: a scanner reports its twelve digits as an EAN-13 with a
    /// leading zero, which this accepts unchanged.
    public static func isBarcode(_ payload: String) -> Bool {
        // ASCII only. `wholeNumberValue` alone would read an Arabic-Indic numeral or a superscript
        // as a digit, and no scanner emits those.
        let digits = payload.compactMap { $0.isASCII ? $0.wholeNumberValue : nil }
        guard digits.count == Constants.barcodeDigitCount, digits.count == payload.count else {
            return false
        }

        // Alternating weights of one and three from the left. The check digit falls on a weight of
        // one and is chosen to bring the weighted total to a multiple of ten, so including it makes
        // the test a single sum rather than a sum and a comparison.
        let weightedTotal = digits.enumerated().reduce(0) { total, digit in
            total + digit.element * (digit.offset.isMultiple(of: 2) ? 1 : 3)
        }
        return weightedTotal.isMultiple(of: 10)
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

private enum Constants {
    /// EAN-13, which is also where a twelve-digit UPC-A arrives once its leading zero is added.
    static let barcodeDigitCount = 13
}
