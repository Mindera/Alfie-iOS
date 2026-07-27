import SharedUI
import SwiftUI
import XCTest
@testable import ProductListing

final class ProductListingListStyleSelectorStyleTests: XCTestCase {
    // The selected style must be visually distinguishable from the unselected one.
    func test_selectedAndUnselected_iconTintsDiffer() {
        XCTAssertNotEqual(
            ProductListingListStyleSelector.Style.iconTint(isSelected: true),
            ProductListingListStyleSelector.Style.iconTint(isSelected: false)
        )
    }

    func test_iconTint_usesSemanticTokens() {
        XCTAssertEqual(ProductListingListStyleSelector.Style.iconTint(isSelected: true), Theme.contentContentPrimary)
        XCTAssertEqual(ProductListingListStyleSelector.Style.iconTint(isSelected: false), Theme.borderSoft)
    }
}
