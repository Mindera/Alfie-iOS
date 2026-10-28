import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class PageControlGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_secondPageSelected() {
        let sut = ThemedPageControl(data: [1, 2, 3, 4], selectedIndex: .constant(1), configuration: .init())
        assertSnapshot(of: sut.embededInContainer(height: 80), as: .defaultImage(), record: isRecording)
    }
}
