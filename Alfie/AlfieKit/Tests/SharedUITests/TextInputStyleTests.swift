import SwiftUI
import XCTest
@testable import SharedUI

// Assertions pin the *resolved* Color value each state maps to (SwiftUI value-equality), not the
// token identity — same-valued Theme aliases are interchangeable as far as these tests can tell.
final class TextInputStyleTests: XCTestCase {
    // MARK: - Border color

    func test_border_color_is_soft_when_idle() {
        let sut = TextInputStyle(isError: false, isFocused: false)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
    }

    func test_border_color_is_content_primary_when_focused() {
        let sut = TextInputStyle(isError: false, isFocused: true)
        XCTAssertEqual(sut.borderColor, Theme.contentContentPrimary)
    }

    func test_border_color_is_negative_when_in_error() {
        let sut = TextInputStyle(isError: true, isFocused: false)
        XCTAssertEqual(sut.borderColor, Theme.contentContentNegative)
    }

    func test_border_color_error_takes_precedence_over_focus() {
        // The min > max error must stay visible while the user is still typing in the field.
        let sut = TextInputStyle(isError: true, isFocused: true)
        XCTAssertEqual(sut.borderColor, Theme.contentContentNegative)
    }

    // MARK: - Border width

    func test_border_width_is_default_when_idle() {
        let sut = TextInputStyle(isError: false, isFocused: false)
        XCTAssertEqual(sut.borderWidth, Sizing.borderBorderWeightDefault)
    }

    func test_border_width_thickens_when_focused_or_in_error() {
        XCTAssertGreaterThan(
            TextInputStyle(isError: false, isFocused: true).borderWidth,
            Sizing.borderBorderWeightDefault
        )
        XCTAssertGreaterThan(
            TextInputStyle(isError: true, isFocused: false).borderWidth,
            Sizing.borderBorderWeightDefault
        )
    }

    // MARK: - Content colors

    func test_value_prefix_and_placeholder_are_distinguishable() {
        let sut = TextInputStyle(isError: false, isFocused: false)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimary)
        XCTAssertEqual(sut.prefixColor, Theme.contentContentTerciary)
        XCTAssertEqual(sut.placeholderColor, Theme.contentContentTerciary)
        XCTAssertNotEqual(sut.textColor, sut.placeholderColor, "A typed value must not read as a placeholder")
    }

    func test_value_color_is_unaffected_by_the_error_state() {
        // Only the border and label carry the error; the number the user typed stays legible.
        let sut = TextInputStyle(isError: true, isFocused: false)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimary)
    }

    func test_label_color_turns_negative_in_error() {
        XCTAssertEqual(TextInputStyle(isError: false, isFocused: false).labelColor, Theme.contentContentTerciary)
        XCTAssertEqual(TextInputStyle(isError: true, isFocused: false).labelColor, Theme.contentContentNegative)
    }

    // MARK: - Disabled

    func test_content_is_muted_when_disabled() {
        let sut = TextInputStyle(isError: false, isFocused: false, isDisabled: true)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimaryDisabled)
        XCTAssertEqual(sut.labelColor, Theme.contentContentPrimaryDisabled)
        XCTAssertEqual(sut.prefixColor, Theme.contentContentPrimaryDisabled)
    }

    func test_border_stays_idle_when_disabled() {
        let sut = TextInputStyle(isError: false, isFocused: true, isDisabled: true)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
        XCTAssertEqual(sut.borderWidth, Sizing.borderBorderWeightDefault)
    }

    // MARK: - Geometry

    func test_height_meets_the_minimum_touch_target() {
        XCTAssertGreaterThanOrEqual(TextInputStyle.height, 44, "Apple HIG minimum tappable height")
    }
}
