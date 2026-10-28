import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ModalGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_sheet() {
        let sut = ThemedModalSheet(
            title: "Modal title",
            modalFitsScreen: .constant(true),
            offset: .constant(.zero),
            backOpacityLayer: .constant(1),
            topMargin: 0,
            onDismiss: {}
        ) {
            Text("Modal content")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        assertSnapshot(of: sut.embededInContainer(height: 400), as: .defaultImage(), record: isRecording)
    }
}
