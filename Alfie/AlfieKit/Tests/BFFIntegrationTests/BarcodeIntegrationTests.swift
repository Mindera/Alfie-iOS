import Model
import XCTest

final class BarcodeIntegrationTests: IntegrationTestCase {
    /// `productByBarcode` only resolves on SCAYLE, and the suite cannot ask the BFF which platform it
    /// is running — nothing forwards that into the test bundle, and an unset `PLATFORM` leaves the
    /// choice to the BFF's own `.env`. So the platform is inferred from the one answer that means
    /// "this platform does not implement this": a 501. Every other failure — auth, schema, a server
    /// having a bad day — fails the test and says what it was, rather than passing as a skip.
    ///
    /// See issue #156 for forwarding the platform properly.
    func test_product_by_barcode_with_unknown_barcode_returns_nil() async throws {
        let match: BarcodeMatch?
        do {
            match = try await sut.productByBarcode("0000000000000")
        } catch let error as BFFRequestError where Self.isUnimplemented(error) {
            throw XCTSkip(
                "productByBarcode is SCAYLE only and this BFF answered 501. "
                    + "https://github.com/Mindera/Alfie-iOS/issues/156"
            )
        }

        XCTAssertNil(match)
    }

    private static func isUnimplemented(_ error: BFFRequestError) -> Bool {
        error.graphqlErrorStatus == notImplemented || error.type == .serverError(status: notImplemented)
    }

    private static let notImplemented = 501
}
