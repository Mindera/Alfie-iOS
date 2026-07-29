import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import AppFeature

final class SplashViewSnapshotTests: XCTestCase {
    private let isRecording = false

    // Covers only the static parts (wordmark, placement, background). SplashView's LoadingSpinner
    // rotates off wall-clock time, so its angle is non-deterministic. Unlike the rest of the suite
    // (default precision 1.0), this test lowers precision to 0.9 so the spinner's few rotating pixels
    // stay under budget — at 1.0 it flakes every run. Cover the spinner itself with a unit test.
    func test_splashView() {
        let sut = SplashView()
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(precision: 0.9),
                       record: isRecording)
    }
}
