import Model
import SwiftUI
import XCTest
@testable import SharedUI

// Assertions pin the *resolved* Color value each state maps to (SwiftUI value-equality), not the
// token identity — same-valued Theme aliases are interchangeable as far as these tests can tell.
final class SizingSwatchAppearanceTests: XCTestCase {
    // MARK: - Selection

    func test_selection_is_a_border_and_never_a_fill() {
        // The pre-redesign chip filled black when selected. This pins the change, so a regression to
        // a fill fails here rather than at design review.
        let sut = SizingSwatchAppearance.resolve(for: .available, isSelected: true)
        XCTAssertEqual(sut.backgroundColor, .clear)
    }

    func test_selected_chip_has_a_heavier_border_than_unselected() {
        let selected = SizingSwatchAppearance.resolve(for: .available, isSelected: true)
        let unselected = SizingSwatchAppearance.resolve(for: .available, isSelected: false)
        XCTAssertGreaterThan(selected.borderWidth, unselected.borderWidth)
    }

    func test_selected_chip_border_is_content_primary() {
        let sut = SizingSwatchAppearance.resolve(for: .available, isSelected: true)
        XCTAssertEqual(sut.borderColor, Theme.contentContentPrimary)
    }

    func test_unselected_chip_border_is_soft() {
        let sut = SizingSwatchAppearance.resolve(for: .available, isSelected: false)
        XCTAssertEqual(sut.borderColor, Theme.borderSoft)
    }

    // MARK: - States

    func test_available_chip_text_is_content_primary() {
        let sut = SizingSwatchAppearance.resolve(for: .available, isSelected: false)
        XCTAssertEqual(sut.textColor, Theme.contentContentPrimary)
    }

    func test_out_of_stock_chip_is_crossed_out_and_dimmed() {
        let sut = SizingSwatchAppearance.resolve(for: .outOfStock, isSelected: false)
        XCTAssertTrue(sut.isCrossedOut)
        XCTAssertEqual(sut.textColor, Theme.contentContentTerciary)
    }

    func test_unavailable_chip_is_dimmed_but_not_crossed_out() {
        let sut = SizingSwatchAppearance.resolve(for: .unavailable, isSelected: false)
        XCTAssertFalse(sut.isCrossedOut)
        XCTAssertEqual(sut.textColor, Theme.contentContentTerciary)
    }

    func test_unbuyable_states_never_fill_or_thicken_even_when_selected() {
        // Selection cannot reach these states through the UI, but nothing in the type prevents it.
        for state in [SizingSwatch.ItemState.outOfStock, .unavailable] {
            let sut = SizingSwatchAppearance.resolve(for: state, isSelected: true)
            XCTAssertEqual(sut.backgroundColor, .clear, "\(state) filled when selected")
            XCTAssertEqual(
                sut.borderWidth,
                SizingSwatchAppearance.resolve(for: .available, isSelected: false).borderWidth,
                "\(state) took the selected border weight"
            )
        }
    }
}
