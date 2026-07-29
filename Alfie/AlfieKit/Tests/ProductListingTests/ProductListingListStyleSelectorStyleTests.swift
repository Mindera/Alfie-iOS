import Model
import SharedUI
import XCTest
@testable import ProductListing

final class ProductListingListStyleSelectorStyleTests: XCTestCase {
    // Selecting a style swaps its icon to the filled variant; unselected stays outline.
    func test_selectedStyle_usesFilledIcon() {
        XCTAssertEqual(ProductListingListStyleSelector.Style.icon(for: .grid, isSelected: true), .grid2Fill)
        XCTAssertEqual(ProductListingListStyleSelector.Style.icon(for: .list, isSelected: true), .grid1Fill)
    }

    func test_unselectedStyle_usesOutlineIcon() {
        XCTAssertEqual(ProductListingListStyleSelector.Style.icon(for: .grid, isSelected: false), .grid)
        XCTAssertEqual(ProductListingListStyleSelector.Style.icon(for: .list, isSelected: false), .listplp)
    }

    // Selection must be visually distinguishable: the icon differs between states.
    func test_selectedAndUnselected_iconsDiffer() {
        XCTAssertNotEqual(
            ProductListingListStyleSelector.Style.icon(for: .grid, isSelected: true),
            ProductListingListStyleSelector.Style.icon(for: .grid, isSelected: false)
        )
        XCTAssertNotEqual(
            ProductListingListStyleSelector.Style.icon(for: .list, isSelected: true),
            ProductListingListStyleSelector.Style.icon(for: .list, isSelected: false)
        )
    }
}
