import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class RadioButtonGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_states() {
        let sut = VStack(alignment: .leading, spacing: 16) {
            RadioButton(state: .constant(.selected), text: "Selected")
            RadioButton(state: .constant(.unselected), text: "Unselected")
            RadioButton(state: .constant(.disabled), text: "Disabled")
        }
        assertSnapshot(of: sut.embededInContainer(height: 160), as: .defaultImage(), record: isRecording)
    }
}
