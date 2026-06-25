import XCTest
@testable import SharedUI

/// Pins every `CornerRadius` case to its expected point value AND to the radius token it is
/// sourced from (ALFMOB-270). The JSON defines only `radiusSoft`=4 and `radiusStrong`=16 for
/// finite radii, so cases map by size (< 10 → soft, ≥ 10 → strong); `full` stays on
/// `radiusRounded`; `none` is the absence of a radius (0, no token).
final class CornerRadiusTokenTests: XCTestCase {
    func test_corner_radius_values_match_expected_points() {
        XCTAssertEqual(CornerRadius.none, 0)
        XCTAssertEqual(CornerRadius.xxs, 4)
        XCTAssertEqual(CornerRadius.xs, 4)
        XCTAssertEqual(CornerRadius.s, 4)
        XCTAssertEqual(CornerRadius.m, 16)
        XCTAssertEqual(CornerRadius.l, 16)
        XCTAssertEqual(CornerRadius.xl, 16)
        XCTAssertEqual(CornerRadius.full, 1000)
    }

    func test_corner_radius_is_sourced_from_radius_tokens() {
        XCTAssertEqual(CornerRadius.xxs, Sizing.radiusSoft)
        XCTAssertEqual(CornerRadius.xs, Sizing.radiusSoft)
        XCTAssertEqual(CornerRadius.s, Sizing.radiusSoft)
        XCTAssertEqual(CornerRadius.m, Sizing.radiusStrong)
        XCTAssertEqual(CornerRadius.l, Sizing.radiusStrong)
        XCTAssertEqual(CornerRadius.xl, Sizing.radiusStrong)
        XCTAssertEqual(CornerRadius.full, Sizing.radiusRounded)
    }
}
