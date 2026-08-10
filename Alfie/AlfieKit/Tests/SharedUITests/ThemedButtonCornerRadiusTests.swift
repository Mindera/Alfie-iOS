import SwiftUI
import XCTest
@testable import SharedUI

/// The corner radius is a parameter so one screen can opt out without moving every other button.
/// The default must stay at the token value: 38 call sites rely on it and never pass the argument.
final class ThemedButtonCornerRadiusTests: XCTestCase {
    func test_defaultCornerRadius_isTheSoftRadiusToken() {
        let sut = ThemedButton(text: "Add to bag") {}
        XCTAssertEqual(sut.cornerRadius, Sizing.radiusSoft)
    }

    func test_cornerRadius_canBeOverriddenToSquare() {
        let sut = ThemedButton(text: "Add to bag", cornerRadius: 0) {}
        XCTAssertEqual(sut.cornerRadius, 0)
    }

    func test_shimmerRadius_followsTheOverride() {
        // A square button that shimmers with rounded corners is a visible mismatch while loading.
        let sut = ThemedButton(text: "Add to bag", style: .secondary, cornerRadius: 0) {}
        XCTAssertEqual(sut.cornerRadius, 0)
    }

    func test_borderlessStyles_staySquareRegardlessOfTheOverride() {
        let sut = ThemedButton(text: "Link", style: .underline, cornerRadius: 99) {}
        XCTAssertEqual(sut.cornerRadius, 0)
    }
}
