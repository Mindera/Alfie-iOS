import SwiftUI
import XCTest
@testable import SharedUI

// Assertions pin the *resolved* Color value each state maps to (SwiftUI value-equality), not the
// token identity — same-valued Theme aliases are interchangeable as far as these tests can tell.
final class ColorCardAppearanceTests: XCTestCase {
    // MARK: - Selection

    func test_selected_card_has_a_heavier_border_than_unselected() {
        let selected = ColorCardAppearance.resolve(isSelected: true, isDisabled: false)
        let unselected = ColorCardAppearance.resolve(isSelected: false, isDisabled: false)
        XCTAssertGreaterThan(selected.borderWidth, unselected.borderWidth)
    }

    func test_selected_card_border_is_content_primary() {
        let sut = ColorCardAppearance.resolve(isSelected: true, isDisabled: false)
        XCTAssertEqual(sut.borderColor, Theme.contentContentPrimary)
    }

    func test_unselected_card_border_is_soft() {
        let sut = ColorCardAppearance.resolve(isSelected: false, isDisabled: false)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
    }

    // MARK: - Unavailable colours

    func test_disabled_card_dims_its_name() {
        let sut = ColorCardAppearance.resolve(isSelected: false, isDisabled: true)
        XCTAssertEqual(sut.textColor, Theme.contentContentTerciary)
    }

    // A disabled colour cannot be chosen, so it must never draw the selected border — otherwise a
    // selection that goes out of stock keeps reading as selectable.
    func test_disabled_card_never_draws_the_selected_border() {
        let sut = ColorCardAppearance.resolve(isSelected: true, isDisabled: true)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
        XCTAssertEqual(
            sut.borderWidth,
            ColorCardAppearance.resolve(isSelected: false, isDisabled: false).borderWidth
        )
    }
}
