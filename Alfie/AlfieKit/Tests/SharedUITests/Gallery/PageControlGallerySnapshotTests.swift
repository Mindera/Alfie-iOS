import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class PageControlGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_page_control_with_second_page_selected_highlights_it() {
        let sut = ThemedPageControl(data: [1, 2, 3, 4], selectedIndex: .constant(1), configuration: .init())
        assertSnapshot(of: sut.embededInContainer(height: 80), as: .defaultImage(), record: isRecording)
    }
}
