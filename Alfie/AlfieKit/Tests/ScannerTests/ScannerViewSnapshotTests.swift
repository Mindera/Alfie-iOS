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
/// laid out over the preview rather than beside it. The failure cases cover the opposite — the
/// chrome over a plain background, where there is no camera to invert against.
final class ScannerViewSnapshotTests: XCTestCase {
    private let isRecording = false

    private static let guidance = "Point the camera at the Alfie code on the tag"

    func test_scannerView() {
        let sut = ScannerView(viewModel: MockScannerViewModel(state: .success(.init(guidance: Self.guidance))))
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// Guidance long enough to wrap: the panel grows with the text rather than clipping it.
    func test_scannerView_withLongGuidance() {
        let viewModel = MockScannerViewModel(
            state: .success(.init(guidance: String(repeating: "\(Self.guidance). ", count: 3)))
        )
        let sut = ScannerView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The notice sits above the guidance rather than replacing it: what went wrong and what to do
    /// next are both on screen, over a camera that never stopped.
    func test_scannerView_withNotice() {
        let viewModel = MockScannerViewModel(
            state: .success(
                .init(
                    guidance: Self.guidance,
                    notice: .init(id: 1, message: "That code doesn't open anything in Alfie.")
                )
            )
        )
        let sut = ScannerView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The longest thing the scanner says, and the one most likely to be read in a hurry over a live
    /// camera: it names what was scanned *and* what to scan instead, so it wraps where the shorter
    /// notice does not.
    func test_scannerView_withBarcodeNotice() {
        let viewModel = MockScannerViewModel(
            state: .success(
                .init(
                    guidance: Self.guidance,
                    notice: .init(id: 1, message: "That's the product barcode. Scan the Alfie code on the tag instead.")
                )
            )
        )
        let sut = ScannerView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scannerView_withPermissionDenied() {
        let sut = ScannerView(viewModel: MockScannerViewModel(state: .error(.cameraPermissionDenied)))
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scannerView_withDeviceNotSupported() {
        let sut = ScannerView(viewModel: MockScannerViewModel(state: .error(.deviceNotSupported)))
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The camera exists and is permitted, but would not start. It has no headline and no way out,
    /// so it renders a shorter panel than the other two — which is exactly what a reference is for.
    func test_scannerView_withGenericFailure() {
        let sut = ScannerView(viewModel: MockScannerViewModel(state: .error(.generic)))
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
