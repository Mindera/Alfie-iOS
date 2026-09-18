import Model
import Vision
import XCTest
@testable import Core

/// The rule that decides what the camera hands the ViewModel. It lives beside the delegate callback
/// rather than inside it, because `RecognizedItem` cannot be built in a test.
final class CameraScanPayloadTests: XCTestCase {
    func test_qr_is_read_as_an_alfie_code() {
        XCTAssertEqual(
            CameraScanService.payload(for: .qr, value: "alfie://alfie.target/product/88"),
            .qr("alfie://alfie.target/product/88")
        )
    }

    func test_ean13_is_read_as_a_barcode() {
        XCTAssertEqual(CameraScanService.payload(for: .ean13, value: "8719992755325"), .ean13("8719992755325"))
    }

    /// EAN-8 is the one the catalogue also carries, and the scanner is not asked to recognise it.
    /// Reading it as an EAN-13 would send the BFF a code no Product can match.
    func test_other_symbologies_are_ignored() {
        for symbology in [VNBarcodeSymbology.ean8, .code128, .pdf417, .aztec] {
            XCTAssertNil(CameraScanService.payload(for: symbology, value: "8719992"), "\(symbology)")
        }
    }

    func test_a_code_the_scanner_could_not_read_is_ignored() {
        XCTAssertNil(CameraScanService.payload(for: .qr, value: nil))
        XCTAssertNil(CameraScanService.payload(for: .ean13, value: nil))
    }
}
