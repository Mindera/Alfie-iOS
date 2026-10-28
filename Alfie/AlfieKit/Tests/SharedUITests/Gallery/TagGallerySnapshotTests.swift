import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class TagGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_tag_renders_every_variant() {
        let sut = VStack(spacing: 16) {
            Tag(configuration: .init(label: "Label"))
            Tag(configuration: .init(label: "Closable", showCloseButton: true))
            Tag(configuration: .init(label: "With icon", icon: Icon.info.image))
            Tag(configuration: .init(label: "Icon and close", showCloseButton: true, icon: Icon.info.image))
        }
        assertSnapshot(of: sut.embededInContainer(height: 240), as: .defaultImage(), record: isRecording)
    }
}
