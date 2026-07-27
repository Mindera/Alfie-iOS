import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import AppFeature

final class SplashViewSnapshotTests: XCTestCase {
    private let isRecording = false

    func test_splashView() {
        let sut = SplashView()
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
