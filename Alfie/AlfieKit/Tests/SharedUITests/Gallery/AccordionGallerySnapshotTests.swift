import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class AccordionGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_accordion_renders_every_variant() {
        let sut = VStack(spacing: 0) {
            AccordionView(text: "Small, closed") { Text("Content") }
            AccordionView(text: "Small, open", isOpen: true, notFirst: true) { Text("Content") }
            AccordionView(text: "Large, closed", type: .large, notFirst: true) { Text("Content") }
            AccordionView(text: "Disabled", isDisabled: .constant(true), notFirst: true) { Text("Content") }
        }
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 360), as: .defaultImage(), record: isRecording)
    }
}
