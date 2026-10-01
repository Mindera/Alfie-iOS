import Mocks
import Model
import SharedUI
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Scanner

/// The scanner's chrome, over a stand-in for the camera feed.
///
/// The preview comes from the scan service, so `MockCameraScanService` renders a blank one and the
/// snapshot covers what this screen actually owns: the header, the viewfinder and the guidance,
/// laid out over the preview rather than beside it. The failure cases cover the opposite — the
/// chrome over a plain background, where there is no camera to invert against.
final class ScannerViewSnapshotTests: XCTestCase {
    private let isRecording = false

    /// Fixed stand-in copy rather than the shipped `L10n` strings: these snapshots pin the layout,
    /// and the wording is the localization tests' business. Set to today's copy, so the references
    /// stay valid, and a later reword moves the strings without re-recording seven images.
    private static let guidance = "Point the camera at the Alfie code on the tag"
    private static let title = "Scan"

    private static func makeViewModel(
        state: ViewState<ScannerViewStateModel, ScannerViewErrorType>
    ) -> MockScannerViewModel {
        MockScannerViewModel(title: title, state: state)
    }

    func test_scanner_view_scanning() {
        let sut = ScannerView(viewModel: Self.makeViewModel(state: .success(.init(guidance: Self.guidance))))

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// Guidance long enough to wrap: the panel grows with the text rather than clipping it.
    func test_scanner_view_with_long_guidance() {
        let viewModel = Self.makeViewModel(
            state: .success(.init(guidance: String(repeating: "\(Self.guidance). ", count: 3)))
        )
        let sut = ScannerView(viewModel: viewModel)

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The notice sits below the guidance rather than replacing it: what went wrong and what to do
    /// next are both on screen, over a camera that never stopped.
    func test_scanner_view_with_notice() {
        let viewModel = Self.makeViewModel(
            state: .success(
                .init(
                    guidance: Self.guidance,
                    notice: .init(id: 1, message: "We don't recognize this barcode.")
                )
            )
        )
        let sut = ScannerView(viewModel: viewModel)

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scanner_view_recognised() {
        let viewModel = Self.makeViewModel(state: .success(.init(guidance: Self.guidance, isRecognised: true)))
        let sut = ScannerView(viewModel: viewModel)

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scanner_view_looking_up() {
        let viewModel = Self.makeViewModel(state: .success(.init(guidance: Self.guidance, isLookingUp: true)))
        let sut = ScannerView(viewModel: viewModel)

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scanner_intro_view() {
        let sut = ScannerIntroView(onContinue: {}, onNotNow: {})

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scanner_view_with_permission_denied() {
        let sut = ScannerView(viewModel: Self.makeViewModel(state: .error(.cameraPermissionDenied)))

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_scanner_view_with_device_not_supported() {
        let sut = ScannerView(viewModel: Self.makeViewModel(state: .error(.deviceNotSupported)))

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The camera exists and is permitted, but would not start. It has no headline and no way out,
    /// so it renders a shorter panel than the other two — which is exactly what a reference is for.
    func test_scanner_view_with_generic_failure() {
        let sut = ScannerView(viewModel: Self.makeViewModel(state: .error(.generic)))

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
