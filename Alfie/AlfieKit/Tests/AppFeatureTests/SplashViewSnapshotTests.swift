import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import AppFeature

final class SplashViewSnapshotTests: XCTestCase {
    private let isRecording = false

    // Covers the wordmark, its placement and the background. NOT the spinner: LoadingSpinner rotates off
    // wall-clock time, so its angle differs every run — it only passes because it is well under the
    // precision budget. Raising precision to catch it makes the test flake instead.
    func test_splashView() {
        let sut = SplashView()
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
