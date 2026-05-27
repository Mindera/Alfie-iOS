@testable import Core
import Foundation
import Model
import XCTest

final class BFFErrorTelemetryTests: XCTestCase {
    // MARK: - Category mapping

    func test_category_rate_limited() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .rateLimited(retryAfter: nil)), "rate_limited")
    }

    func test_category_timeout() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .timeout), "timeout")
    }

    func test_category_server_error() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .serverError(status: 503)), "server_error")
    }

    func test_category_no_internet() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .noInternet), "network")
    }

    func test_category_product() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .product(.noProduct)), "graphql")
    }

    func test_category_empty_response() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .emptyResponse), "graphql")
    }

    func test_category_generic() {
        XCTAssertEqual(BFFErrorTelemetry.category(for: .generic), "generic")
    }

    // MARK: - Crashlytics non-fatal routing

    func test_records_server_error_as_non_fatal() {
        XCTAssertTrue(BFFErrorTelemetry.shouldRecordAsNonFatal(.serverError(status: 503)))
    }

    func test_records_generic_as_non_fatal() {
        XCTAssertTrue(BFFErrorTelemetry.shouldRecordAsNonFatal(.generic))
    }

    func test_does_not_record_graphql_empty_results_as_non_fatal() {
        // Empty-results signals are legitimate UI states, not failures.
        XCTAssertFalse(BFFErrorTelemetry.shouldRecordAsNonFatal(.product(.generic)))
        XCTAssertFalse(BFFErrorTelemetry.shouldRecordAsNonFatal(.product(.noProduct)))
        XCTAssertFalse(BFFErrorTelemetry.shouldRecordAsNonFatal(.emptyResponse))
    }

    func test_does_not_record_rate_limited_as_non_fatal() {
        // Operational signal — keep Crashlytics dashboard quiet.
        XCTAssertFalse(BFFErrorTelemetry.shouldRecordAsNonFatal(.rateLimited(retryAfter: nil)))
    }

    func test_does_not_record_timeout_as_non_fatal() {
        XCTAssertFalse(BFFErrorTelemetry.shouldRecordAsNonFatal(.timeout))
    }

    func test_does_not_record_no_internet_as_non_fatal() {
        XCTAssertFalse(BFFErrorTelemetry.shouldRecordAsNonFatal(.noInternet))
    }
}
