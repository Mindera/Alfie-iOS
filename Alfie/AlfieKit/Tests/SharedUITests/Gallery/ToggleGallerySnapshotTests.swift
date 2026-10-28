import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ToggleGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_states() {
        let sut = VStack(spacing: 16) {
            ThemedToggleView(isOn: .constant(true)) { Text("On") }
            ThemedToggleView(isOn: .constant(false)) { Text("Off") }
            ThemedToggleView(isOn: .constant(true), isDisabled: .constant(true)) { Text("On, disabled") }
            ThemedToggleView(isOn: .constant(false), isDisabled: .constant(true)) { Text("Off, disabled") }
        }
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 260), as: .defaultImage(), record: isRecording)
    }
}
