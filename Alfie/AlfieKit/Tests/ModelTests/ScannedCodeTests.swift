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
    func test_is_barcode_with_thirteen_digits_and_valid_check_digit_is_true() {
        for payload in ["5901234123457", "4006381333931", "0012345678905"] {
            let isBarcode = ScannedCode.isBarcode(payload)

            XCTAssertTrue(isBarcode, "Expected \(payload) to be a Barcode")
        }
    }

    /// The check digit is the whole point of testing more than the shape: a QR code holding thirteen
    /// digits would otherwise be answered with "that's the product barcode", which is a confident
    /// lie. A camera validates the check digit before reporting an EAN-13, so no real Barcode is
    /// lost by insisting on it.
    func test_is_barcode_with_wrong_check_digit_is_false() {
        let isBarcode = ScannedCode.isBarcode("5901234123456")

        XCTAssertFalse(isBarcode)
    }

    func test_is_barcode_with_payload_not_thirteen_digits_is_false() {
        for payload in ["", "590123412345", "59012341234570", "https://localhost:4000/product/jean"] {
            let isBarcode = ScannedCode.isBarcode(payload)

            XCTAssertFalse(isBarcode, "Expected \(payload) not to be a Barcode")
        }
    }

    /// Digits, not merely digit-*ish*: `compactMap` over character values would count an Arabic-Indic
    /// numeral or a superscript as one, and a payload of them is not a number any scanner emitted.
    func test_is_barcode_with_digit_like_characters_is_false() {
        for payload in ["٥٩٠١٢٣٤١٢٣٤٥٧", "5901234¹23457", "5901234 123457"] {
            let isBarcode = ScannedCode.isBarcode(payload)

            XCTAssertFalse(isBarcode, "Expected \(payload) not to be a Barcode")
        }
    }

    // MARK: - Choosing between codes read together

    /// A Swing tag prints both codes side by side, so a camera held over one sees both. The shopper
    /// who scanned correctly must not be corrected for the Barcode that happened to share the frame.
    func test_code_to_act_on_with_alfie_code_beside_barcode_is_alfie_code() throws {
        let url = try XCTUnwrap(URL(string: "https://localhost:4000/product/slim-indigo-jean"))
        let codes: [ScannedCode] = [.barcode(value: "5901234123457"), .alfieCode(url)]

        let code = codes.codeToActOn

        XCTAssertEqual(code, .alfieCode(url))
    }

    /// "Scan the other code on this tag" is more use than "that opens nothing", so when neither is
    /// ours the Barcode is the one worth mentioning.
    func test_code_to_act_on_with_barcode_beside_unrecognised_code_is_barcode() {
        let codes: [ScannedCode] = [.unrecognised(payload: "hello"), .barcode(value: "5901234123457")]

        let code = codes.codeToActOn

        XCTAssertEqual(code, .barcode(value: "5901234123457"))
    }

    /// Between equals the camera's own order stands, so a frame of two strangers' codes reports the
    /// one it saw first rather than an arbitrary pick.
    func test_code_to_act_on_with_equally_ranked_codes_keeps_camera_order() {
        let codes: [ScannedCode] = [.unrecognised(payload: "first"), .unrecognised(payload: "second")]

        let code = codes.codeToActOn

        XCTAssertEqual(code, .unrecognised(payload: "first"))
    }

    func test_code_to_act_on_with_no_codes_is_nil() {
        let codes: [ScannedCode] = []

        let code = codes.codeToActOn

        XCTAssertNil(code)
    }
}
