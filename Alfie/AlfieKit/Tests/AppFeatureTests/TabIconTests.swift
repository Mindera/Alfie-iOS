import Model
import SharedUI
import XCTest

final class TabIconTests: XCTestCase {
    // Tabs with a filled glyph in the design system must swap to it when selected.
    func test_tabsWithFillVariant_useADifferentGlyphWhenSelected() {
        for tab in [Model.Tab.home, .bag, .wishlist, .account] {
            XCTAssertNotEqual(
                tab.icon(isSelected: true),
                tab.icon(isSelected: false),
                "\(tab) should use its filled glyph when selected"
            )
        }
    }

    // Shop has no fill variant, so selection must not change its glyph.
    func test_shopTab_hasNoFillVariant() {
        XCTAssertEqual(
            Model.Tab.shop.icon(isSelected: true),
            Model.Tab.shop.icon(isSelected: false)
        )
    }
}
