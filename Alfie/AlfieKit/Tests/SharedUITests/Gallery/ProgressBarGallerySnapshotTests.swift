import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ProgressBarGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_progress_bar_renders_empty_half_and_full() {
        let sut = VStack(spacing: 24) {
            ProgressBar(progress: .constant(0), total: 10)
            ProgressBar(progress: .constant(5), total: 10)
            ProgressBar(progress: .constant(10), total: 10)
        }
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 120), as: .defaultImage(), record: isRecording)
    }
}
