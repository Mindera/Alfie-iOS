import Model
import XCTest

/// Telling a manufacturer Barcode from everything else the camera reads, and deciding which of the
/// codes on a Swing tag the scanner acts on.
///
/// Both are pure judgements on what was read, so they are asserted here rather than through the
/// screen: the ViewModel's tests are about what the shopper is then told.
final class ScannedCodeTests: XCTestCase {
    // MARK: - Recognising a Barcode

    /// Real Barcodes, check digits and all: two EAN-13s, and a UPC-A — which a scanner reports as an
    /// EAN-13 with a leading zero, so the twelve-digit form never reaches this test.
    func test_aThirteenDigitPayloadWithAValidCheckDigitIsABarcode() {
        for payload in ["5901234123457", "4006381333931", "0012345678905"] {
            XCTAssertTrue(ScannedCode.isBarcode(payload), "Expected \(payload) to be a Barcode")
        }
    }

    /// The check digit is the whole point of testing more than the shape: a QR code holding thirteen
    /// digits would otherwise be answered with "that's the product barcode", which is a confident
    /// lie. A camera validates the check digit before reporting an EAN-13, so no real Barcode is
    /// lost by insisting on it.
    func test_aThirteenDigitPayloadWithTheWrongCheckDigitIsNotABarcode() {
        XCTAssertFalse(ScannedCode.isBarcode("5901234123456"))
    }

    func test_aPayloadThatIsNotThirteenDigitsIsNotABarcode() {
        for payload in ["", "590123412345", "59012341234570", "https://localhost:4000/product/jean"] {
            XCTAssertFalse(ScannedCode.isBarcode(payload), "Expected \(payload) not to be a Barcode")
        }
    }

    /// Digits, not merely digit-*ish*: `compactMap` over character values would count an Arabic-Indic
    /// numeral or a superscript as one, and a payload of them is not a number any scanner emitted.
    func test_aPayloadOfDigitLikeCharactersIsNotABarcode() {
        for payload in ["٥٩٠١٢٣٤١٢٣٤٥٧", "5901234¹23457", "5901234 123457"] {
            XCTAssertFalse(ScannedCode.isBarcode(payload), "Expected \(payload) not to be a Barcode")
        }
    }

    // MARK: - Choosing between codes read together

    /// A Swing tag prints both codes side by side, so a camera held over one sees both. The shopper
    /// who scanned correctly must not be corrected for the Barcode that happened to share the frame.
    func test_anAlfieCodeReadAlongsideABarcodeIsTheOneActedOn() throws {
        let url = try XCTUnwrap(URL(string: "https://localhost:4000/product/slim-indigo-jean"))
        let codes: [ScannedCode] = [.barcode(value: "5901234123457"), .alfieCode(url)]

        XCTAssertEqual(codes.actionable, .alfieCode(url))
    }

    /// "Scan the other code on this tag" is more use than "that opens nothing", so when neither is
    /// ours the Barcode is the one worth mentioning.
    func test_aBarcodeReadAlongsideAnUnrecognisedCodeIsTheOneActedOn() {
        let codes: [ScannedCode] = [.unrecognised(payload: "hello"), .barcode(value: "5901234123457")]

        XCTAssertEqual(codes.actionable, .barcode(value: "5901234123457"))
    }

    /// Between equals the camera's own order stands, so a frame of two strangers' codes reports the
    /// one it saw first rather than an arbitrary pick.
    func test_equallyRankedCodesKeepTheOrderTheCameraReportedThem() {
        let codes: [ScannedCode] = [.unrecognised(payload: "first"), .unrecognised(payload: "second")]

        XCTAssertEqual(codes.actionable, .unrecognised(payload: "first"))
    }

    func test_aFrameWithNoCodesInItHasNothingToActOn() {
        XCTAssertNil([ScannedCode]().actionable)
    }
}
