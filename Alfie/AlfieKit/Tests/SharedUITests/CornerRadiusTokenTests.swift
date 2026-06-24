import XCTest
@testable import SharedUI

/// Pins every `CornerRadius` case to its expected point value AND to the generated design-token
/// it is sourced from (ALFMOB-270). The JSON defines only three radius tokens
/// (`radiusSoft`=4, `radiusStrong`=16, `radiusRounded`=1000); the remaining cases are sourced
/// from the equivalent spacing primitives.
final class CornerRadiusTokenTests: XCTestCase {
    func test_corner_radius_values_match_expected_points() {
        XCTAssertEqual(CornerRadius.none, 0)
        XCTAssertEqual(CornerRadius.xxs, 2)
        XCTAssertEqual(CornerRadius.xs, 4)
        XCTAssertEqual(CornerRadius.s, 8)
        XCTAssertEqual(CornerRadius.m, 12)
        XCTAssertEqual(CornerRadius.l, 16)
        XCTAssertEqual(CornerRadius.xl, 24)
        XCTAssertEqual(CornerRadius.full, 1000)
    }

    func test_corner_radius_is_sourced_from_generated_tokens() {
        XCTAssertEqual(CornerRadius.none, Primitives.Spacing.spacing0)
        XCTAssertEqual(CornerRadius.xxs, Primitives.Spacing.spacing2)
        XCTAssertEqual(CornerRadius.xs, Sizing.radiusSoft)
        XCTAssertEqual(CornerRadius.s, Primitives.Spacing.spacing8)
        XCTAssertEqual(CornerRadius.m, Primitives.Spacing.spacing12)
        XCTAssertEqual(CornerRadius.l, Sizing.radiusStrong)
        XCTAssertEqual(CornerRadius.xl, Primitives.Spacing.spacing24)
        XCTAssertEqual(CornerRadius.full, Sizing.radiusRounded)
    }
}
