import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class DividerGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_variants() {
        let sut = VStack(spacing: 32) {
            ThemedDivider.horizontalThin
            ThemedDivider.horizontalThick
            HStack(spacing: 32) {
                ThemedDivider.verticalThin
                ThemedDivider.verticalThick
            }
            .frame(height: 48)
        }
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 200), as: .defaultImage(), record: isRecording)
    }
}
