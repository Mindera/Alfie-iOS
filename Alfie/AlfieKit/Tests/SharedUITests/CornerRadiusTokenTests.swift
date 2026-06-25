import XCTest
@testable import SharedUI

/// Pins every `CornerRadius` case to its expected point value AND to the radius token it is
/// sourced from (ALFMOB-270). The design system defines two finite radii (`radiusSoft`=4,
/// `radiusStrong`=16) plus the `radiusRounded` (1000) pill.
final class CornerRadiusTokenTests: XCTestCase {
    func test_corner_radius_values_match_expected_points() {
        XCTAssertEqual(CornerRadius.soft, 4)
        XCTAssertEqual(CornerRadius.strong, 16)
        XCTAssertEqual(CornerRadius.rounded, 1000)
    }

    func test_corner_radius_is_sourced_from_radius_tokens() {
        XCTAssertEqual(CornerRadius.soft, Sizing.radiusSoft)
        XCTAssertEqual(CornerRadius.strong, Sizing.radiusStrong)
        XCTAssertEqual(CornerRadius.rounded, Sizing.radiusRounded)
    }
}
