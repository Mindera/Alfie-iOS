import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class SegmentedControlGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    private let segments = [
        Segment(id: "categories", title: "Categories", "categories"),
        Segment(id: "brands", title: "Brands", "brands"),
        Segment(id: "services", title: "Services", icon: Icon.info.image, "services"),
    ]

    func test_compact() {
        assertGallery(of: .compact)
    }

    func test_extended() {
        assertGallery(of: .extended)
    }

    private func assertGallery(of type: ThemedSegmentType, testName: String = #function) {
        let selection = Binding.constant(segments[0])
        let sut = ThemedSegmentedView(segments, type: type, selection: selection) { segment, animation, type in
            ThemedSegmentView(segment, type: type, currectSelected: selection, animation: animation)
        }
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 120),
                       as: .defaultImage(),
                       record: isRecording,
                       testName: testName)
    }
}
