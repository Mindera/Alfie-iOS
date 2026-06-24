import XCTest
@testable import SharedUI

/// Pins every `Spacing.space*` constant to its expected point value AND to the generated
/// design-token primitive it is sourced from (ALFMOB-270). A wrong-token wiring
/// (e.g. `space200 = spacing18`) fails here instead of shipping a silent layout shift.
final class SpacingTokenTests: XCTestCase {
    func test_spacing_values_match_expected_points() {
        XCTAssertEqual(Spacing.space0, 0)
        XCTAssertEqual(Spacing.space025, 2)
        XCTAssertEqual(Spacing.space050, 4)
        XCTAssertEqual(Spacing.space075, 8) // 6→8: conformed to nearest token (no spacing-6)
        XCTAssertEqual(Spacing.space100, 8)
        XCTAssertEqual(Spacing.space150, 12)
        XCTAssertEqual(Spacing.space200, 16)
        XCTAssertEqual(Spacing.space250, 20)
        XCTAssertEqual(Spacing.space300, 24)
        XCTAssertEqual(Spacing.space400, 32)
        XCTAssertEqual(Spacing.space500, 40)
        XCTAssertEqual(Spacing.space600, 48)
        XCTAssertEqual(Spacing.space700, 56)
        XCTAssertEqual(Spacing.space800, 64)
        XCTAssertEqual(Spacing.space1000, 80)
    }

    func test_spacing_is_sourced_from_generated_primitives() {
        XCTAssertEqual(Spacing.space0, Primitives.Spacing.spacing0)
        XCTAssertEqual(Spacing.space025, Primitives.Spacing.spacing2)
        XCTAssertEqual(Spacing.space050, Primitives.Spacing.spacing4)
        XCTAssertEqual(Spacing.space075, Primitives.Spacing.spacing8)
        XCTAssertEqual(Spacing.space100, Primitives.Spacing.spacing8)
        XCTAssertEqual(Spacing.space150, Primitives.Spacing.spacing12)
        XCTAssertEqual(Spacing.space200, Primitives.Spacing.spacing16)
        XCTAssertEqual(Spacing.space250, Primitives.Spacing.spacing20)
        XCTAssertEqual(Spacing.space300, Primitives.Spacing.spacing24)
        XCTAssertEqual(Spacing.space400, Primitives.Spacing.spacing32)
        XCTAssertEqual(Spacing.space500, Primitives.Spacing.spacing40)
        XCTAssertEqual(Spacing.space600, Primitives.Spacing.spacing48)
        XCTAssertEqual(Spacing.space700, Primitives.Spacing.spacing56)
        XCTAssertEqual(Spacing.space800, Primitives.Spacing.spacing64)
        XCTAssertEqual(Spacing.space1000, Primitives.Spacing.spacing80)
    }
}
