import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ModalGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_modal_sheet_renders_title_and_content() {
        let sut = ThemedModalSheet(
            title: "Modal title",
            topMargin: 0,
            backOpacityLayer: 1,
            onDismiss: {}
        ) {
            Text("Modal content")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        assertSnapshot(of: sut.embededInContainer(height: 400), as: .defaultImage(), record: isRecording)
    }
}
