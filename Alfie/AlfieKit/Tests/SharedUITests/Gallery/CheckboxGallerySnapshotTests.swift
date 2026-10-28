import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class CheckboxGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_states() {
        let sut = VStack(alignment: .leading, spacing: 16) {
            Checkbox(state: .constant(.selected), text: "Selected")
            Checkbox(state: .constant(.unselected), text: "Unselected")
            Checkbox(state: .constant(.disabled), text: "Disabled")
        }
        assertSnapshot(of: sut.embededInContainer(height: 160), as: .defaultImage(), record: isRecording)
    }
}
