import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import AppFeature

final class SplashViewSnapshotTests: XCTestCase {
    private let isRecording = false

    // Covers only the static parts (wordmark, placement, background). SplashView's LoadingSpinner
    // rotates off wall-clock time, so its angle is non-deterministic — it passes only because it is
    // well under the precision budget; raising precision to assert it makes the test flake instead.
    func test_splashView() {
        let sut = SplashView()
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
