import SwiftUI
import XCTest
@testable import SharedUI

// Assertions pin the *resolved* Color value each state maps to (SwiftUI value-equality), not the
// token identity — same-valued Theme aliases are interchangeable as far as these tests can tell.
final class ChipStyleTests: XCTestCase {
    // MARK: - Border color

    func test_border_color_is_soft_when_unselected_and_enabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
    }

    func test_border_color_is_content_primary_when_selected() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.borderColor, Theme.contentContentPrimary)
    }

    func test_border_color_is_surface_foreground_when_disabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.borderColor, Theme.surfaceForegroundPrimary)
    }

    func test_border_color_disabled_takes_precedence_over_selected() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.borderColor, Theme.surfaceForegroundPrimary)
    }

    // MARK: - Text color

    func test_text_color_is_neutrals600_when_enabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.textColor, Primitives.Colours.neutrals600)
    }

    func test_text_color_is_content_primary_disabled_when_disabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimaryDisabled)
    }

    func test_text_color_is_unaffected_by_selection() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.textColor, Primitives.Colours.neutrals600)
    }

    func test_text_color_disabled_takes_precedence_over_selected() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimaryDisabled)
    }

    // MARK: - Background color

    func test_background_color_is_surface_background_when_enabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.backgroundColor, Theme.surfaceBackgroundPrimary)
    }

    func test_background_color_is_surface_foreground_when_disabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.backgroundColor, Theme.surfaceForegroundPrimary)
    }

    func test_background_color_is_unaffected_by_selection() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.backgroundColor, Theme.surfaceBackgroundPrimary)
    }

    func test_background_color_disabled_takes_precedence_over_selected() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.backgroundColor, Theme.surfaceForegroundPrimary)
    }

    // MARK: - Border width

    func test_border_width_normal_uses_border_weight_default_token() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.borderWidth, CGFloat(Primitives.Border.borderWeightDefault))
    }

    func test_border_width_is_thicker_when_selected() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.borderWidth, 2.0)
    }

    func test_border_width_stays_thick_when_selected_and_disabled() {
        let sut = ChipStyle(type: .small, isSelected: true, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.borderWidth, 2.0)
    }

    func test_border_width_is_normal_when_unselected_and_disabled() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: true, counter: nil)
        XCTAssertEqual(sut.borderWidth, CGFloat(Primitives.Border.borderWeightDefault))
    }

    // MARK: - Height

    func test_height_is_36_for_small() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.height, 36.0)
    }

    func test_height_is_44_for_large() {
        let sut = ChipStyle(type: .large, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertEqual(sut.height, 44.0)
    }

    // MARK: - Close-icon size

    func test_close_icon_size_uses_spacing12_token() {
        XCTAssertEqual(ChipStyle.closeWidth, Primitives.Spacing.spacing12)
        XCTAssertEqual(ChipStyle.closeHeight, Primitives.Spacing.spacing12)
    }

    // MARK: - Counter label

    func test_counter_label_is_nil_when_counter_is_nil() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: nil)
        XCTAssertNil(sut.counterLabel)
    }

    func test_counter_label_shows_value_within_max() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: 1)
        XCTAssertEqual(sut.counterLabel, "1")
    }

    func test_counter_label_shows_value_at_max() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: 99)
        XCTAssertEqual(sut.counterLabel, "99")
    }

    func test_counter_label_caps_over_max() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: 100)
        XCTAssertEqual(sut.counterLabel, "99+")
    }

    func test_counter_label_shows_zero() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: 0)
        XCTAssertEqual(sut.counterLabel, "0")
    }

    func test_counter_label_shows_negative_value() {
        let sut = ChipStyle(type: .small, isSelected: false, isDisabled: false, counter: -1)
        XCTAssertEqual(sut.counterLabel, "-1")
    }
}
