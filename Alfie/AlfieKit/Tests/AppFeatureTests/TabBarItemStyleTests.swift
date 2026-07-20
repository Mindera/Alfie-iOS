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

    // Selected label is bolder than unselected (the second selection affordance besides colour).
    func test_selectedLabel_usesHeavierWeightThanUnselected() {
        XCTAssertGreaterThan(
            TabBarItemView.Style.labelStyle(isSelected: true).style.fontWeight,
            TabBarItemView.Style.labelStyle(isSelected: false).style.fontWeight
        )
    }
}
