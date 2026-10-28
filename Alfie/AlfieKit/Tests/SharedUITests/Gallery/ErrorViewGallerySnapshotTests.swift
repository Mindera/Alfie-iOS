import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ErrorViewGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_withTitleMessageAndButton() {
        let sut = ErrorView(
            title: "Something went wrong",
            message: "Please try again in a few moments.",
            buttons: [.init(cta: "Retry") {}]
        )
        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }
}
