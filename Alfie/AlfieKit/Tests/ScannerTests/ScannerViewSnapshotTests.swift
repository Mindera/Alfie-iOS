import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Scanner

/// The scanner's chrome, over a stand-in for the camera feed.
///
/// The preview comes from the scan service, so `MockCameraScanService` renders a blank one and the
/// snapshot covers what this screen actually owns: the title, the close button and the guidance,
/// laid out over the preview rather than beside it.
final class ScannerViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var mockViewModel: MockScannerViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockViewModel = .init()
    }

    override func tearDownWithError() throws {
        mockViewModel = nil
        try super.tearDownWithError()
    }

    func test_scannerView() {
        let sut = ScannerView(viewModel: mockViewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// Guidance long enough to wrap: the panel grows with the text rather than clipping it.
    func test_scannerView_withLongGuidance() {
        mockViewModel.guidance = String(repeating: "Point the camera at the Alfie code on the tag. ", count: 3)
        let sut = ScannerView(viewModel: mockViewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
