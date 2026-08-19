import SwiftUI
import XCTest
@testable import SharedUI

// Assertions pin the *resolved* Color value each state maps to (SwiftUI value-equality), not the
// token identity — same-valued Theme aliases are interchangeable as far as these tests can tell.
final class ColorCardAppearanceTests: XCTestCase {
    // MARK: - Selection

    // Unlike the size chip, the colour card does not thicken its border when selected — the design
    // keeps 1pt throughout and changes the colour and the label weight instead.
    func test_selection_changes_the_border_colour_not_its_width() {
        let selected = ColorCardAppearance.resolve(isSelected: true, isDisabled: false)
        let unselected = ColorCardAppearance.resolve(isSelected: false, isDisabled: false)
        XCTAssertEqual(selected.borderWidth, unselected.borderWidth)
        XCTAssertNotEqual(selected.borderColor, unselected.borderColor)
    }

    func test_selected_card_border_is_content_primary() {
        let sut = ColorCardAppearance.resolve(isSelected: true, isDisabled: false)
        XCTAssertEqual(sut.borderColor, Theme.contentContentPrimary)
    }

    func test_unselected_card_border_is_soft() {
        let sut = ColorCardAppearance.resolve(isSelected: false, isDisabled: false)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
    }

    // On the card, the trait assistive technology reads comes from the same resolver that draws the
    // border, so those two channels cannot disagree. The sheet resolves its own row separately.
    func test_selection_the_card_draws_is_the_selection_it_announces() {
        for isSelected in [true, false] {
            for isDisabled in [true, false] {
                let sut = ColorCardAppearance.resolve(isSelected: isSelected, isDisabled: isDisabled)
                let drawsSelectedBorder = sut.borderColor == Theme.contentContentPrimary
                XCTAssertEqual(sut.isSelected, drawsSelectedBorder, "selected \(isSelected), disabled \(isDisabled)")
            }
        }
    }

    // MARK: - Unavailable colours

    func test_enabled_card_name_is_content_primary() {
        let sut = ColorCardAppearance.resolve(isSelected: false, isDisabled: false)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimary)
    }

    func test_disabled_card_dims_its_name() {
        let sut = ColorCardAppearance.resolve(isSelected: false, isDisabled: true)
        XCTAssertEqual(sut.textColor, Theme.contentContentTerciary)
    }

    // A disabled colour cannot be chosen, so it must never draw the selected border — otherwise a
    // selection that goes out of stock keeps reading as selectable.
    func test_disabled_card_never_draws_the_selected_border() {
        let sut = ColorCardAppearance.resolve(isSelected: true, isDisabled: true)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(
            sut.borderWidth,
            ColorCardAppearance.resolve(isSelected: false, isDisabled: false).borderWidth
        )
    }
}
