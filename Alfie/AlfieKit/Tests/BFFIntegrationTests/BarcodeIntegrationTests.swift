import Model
import TestSeed
import XCTest

final class BarcodeIntegrationTests: IntegrationTestCase {
    /// The Mock BFF and SCAYLE implement `productByBarcode`; a Live BFF started through
    /// `ALFIE_BFF_START_CMD` may run a platform that answers 501. Only that answer skips: every other
    /// failure — auth, schema, a server having a bad day — fails the test and says what it was.
    ///
    /// A bare HTTP 501 with no GraphQL body would fail rather than skip. Which shape a non-SCAYLE
    /// BFF actually answers with is unverified, and guessing it would widen the skip on no evidence.
    func test_product_by_barcode_with_unknown_barcode_returns_nil() async throws {
        let match: BarcodeMatch?
        do {
            match = try await sut.productByBarcode(SeedAnchors.unknownBarcode)
        } catch let error as BFFRequestError where Self.isUnimplemented(error) {
            throw XCTSkip(
                "productByBarcode is SCAYLE only and this BFF answered 501. "
                    + "https://github.com/Mindera/Alfie-iOS/issues/156"
            )
        }

        XCTAssertNil(match)
    }

    /// Only a GraphQL error carrying `extensions.status` can say 501 here. `.serverError` is built
    /// in one place, for the 500/502/503/504 the retry interceptor treats as transient, so a
    /// `.serverError(status: 501)` never occurs and testing for it only implied cover it never had.
    private static func isUnimplemented(_ error: BFFRequestError) -> Bool {
        error.graphqlErrorStatus == notImplemented
    }

    private static let notImplemented = 501
}
