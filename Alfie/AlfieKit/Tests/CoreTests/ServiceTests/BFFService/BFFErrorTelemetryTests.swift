@testable import Core
import Foundation
import Model
import XCTest

final class BFFErrorTelemetryTests: XCTestCase {
    // MARK: - Category mapping

    func test_category_mapping() {
        let cases: [(BFFRequestError.BFFRequestErrorType, String)] = [
            (.rateLimited(retryAfter: nil), "rate_limited"),
            (.rateLimited(retryAfter: 5), "rate_limited"),
            (.timeout, "timeout"),
            (.serverError(status: 500), "server_error"),
            (.serverError(status: 503), "server_error"),
            (.noInternet, "network"),
            (.product(.noProduct), "graphql"),
            (.product(.generic), "graphql"),
            (.emptyResponse, "graphql"),
            (.generic, "generic"),
        ]

        for (type, expected) in cases {
            XCTAssertEqual(BFFErrorTelemetry.category(for: type), expected, "category for \(type)")
        }
    }

    // MARK: - Crashlytics non-fatal routing

    func test_non_fatal_routing() {
        // Only true system failures become non-fatals. Operational signals
        // (rate-limit, timeout, network) and legitimate empty results
        // (.product, .emptyResponse) stay out of Crashlytics.
        let cases: [(BFFRequestError.BFFRequestErrorType, Bool)] = [
            (.serverError(status: 503), true),
            (.serverError(status: 500), true),
            (.generic, true),
            (.product(.generic), false),
            (.product(.noProduct), false),
            (.emptyResponse, false),
            (.rateLimited(retryAfter: nil), false),
            (.timeout, false),
            (.noInternet, false),
        ]

        for (type, expected) in cases {
            XCTAssertEqual(
                BFFErrorTelemetry.shouldRecordAsNonFatal(type),
                expected,
                "shouldRecordAsNonFatal for \(type)"
            )
        }
    }
}
