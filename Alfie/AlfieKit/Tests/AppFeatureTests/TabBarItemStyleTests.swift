import SharedUI
import SwiftUI
import XCTest
@testable import AppFeature

final class TabBarItemStyleTests: XCTestCase {
    // Selection must be visually distinguishable: the selected and unselected
    // treatments must differ for both the icon and the label.
    func test_selectedAndUnselected_iconColoursDiffer() {
        XCTAssertNotEqual(
            TabBarItemView.Style.iconColour(isSelected: true),
            TabBarItemView.Style.iconColour(isSelected: false)
        )
    }

    func test_selectedAndUnselected_labelColoursDiffer() {
        XCTAssertNotEqual(
            TabBarItemView.Style.labelColour(isSelected: true),
            TabBarItemView.Style.labelColour(isSelected: false)
        )
    }
}
