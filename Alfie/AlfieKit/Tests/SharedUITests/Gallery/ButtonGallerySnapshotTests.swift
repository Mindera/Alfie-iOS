import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ButtonGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_primary_button_renders_every_state() {
        assertGallery(of: .primary)
    }

    func test_secondary_button_renders_every_state() {
        assertGallery(of: .secondary)
    }

    func test_tertiary_button_renders_every_state() {
        assertGallery(of: .tertiary)
    }

    func test_underline_button_renders_every_state() {
        assertGallery(of: .underline)
    }

    private func assertGallery(of style: ButtonTheme, testName: String = #function) {
        let sut = VStack(spacing: 16) {
            ThemedButton(text: "Default", style: style) {}
            ThemedButton(text: "Disabled", style: style, isDisabled: .constant(true)) {}
            ThemedButton(text: "Loading", style: style, isLoading: .constant(true)) {}
            ThemedButton(text: "With icons", style: style, leadingAsset: .heart, trailingAsset: .chevronRight) {}
        }
        assertSnapshot(of: sut.embededInContainer(height: 300),
                       as: .defaultImage(),
                       record: isRecording,
                       testName: testName)
    }
}
