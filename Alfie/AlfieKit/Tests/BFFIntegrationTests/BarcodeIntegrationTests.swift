import Model
import XCTest

final class BarcodeIntegrationTests: IntegrationTestCase {
    func test_product_by_barcode_with_unknown_barcode_returns_nil() async throws {
        let match: BarcodeMatch?
        do {
            match = try await sut.productByBarcode("0000000000000")
        } catch is BFFRequestError {
            throw XCTSkip("productByBarcode is SCAYLE only; the local BFF runs another platform")
        }

        XCTAssertNil(match)
    }
}
