import Model
import XCTest

/// Deciding which of the codes on a Swing tag the scanner acts on.
final class ScannedCodeTests: XCTestCase {
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
