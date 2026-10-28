import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class SnackbarGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_types() {
        let sut = VStack(spacing: 16) {
            SnackbarView(configuration: .init(type: .info, text: "Info message", showCloseButton: true))
            SnackbarView(configuration: .init(type: .success, text: "Success message", actionButtonLabel: "Undo"))
            SnackbarView(configuration: .init(type: .error, text: "Error message", icon: Icon.warning.image))
        }
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 300), as: .defaultImage(), record: isRecording)
    }
}
