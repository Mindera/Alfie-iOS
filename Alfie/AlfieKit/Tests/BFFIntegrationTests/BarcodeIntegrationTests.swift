import Model
import XCTest

final class BarcodeIntegrationTests: IntegrationTestCase {
    func test_product_by_barcode_with_unknown_barcode_returns_nil() async throws {
        let match = try await sut.productByBarcode("0000000000000")

        XCTAssertNil(match)
    }
}
