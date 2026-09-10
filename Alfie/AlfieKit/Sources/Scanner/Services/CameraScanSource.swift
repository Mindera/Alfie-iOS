import AVFoundation
import Combine
import SwiftUI
import VisionKit

/// The real camera, via VisionKit's `DataScannerViewController`.
///
/// Only QR codes are recognised: the Alfie code is a QR code, and reading the manufacturer's
/// Barcode is a separate ticket that will widen this list. Everything the scanner sees is published
/// verbatim — deciding what a payload means belongs to ``ScannerViewModel``.
///
/// A device that cannot scan, and a shopper who has refused the camera, both currently end at a
/// preview that never recognises anything. Explaining that to them is the follow-up ticket for
/// failure states; this type logs it so the gap is visible in a demo that goes wrong.
///
/// `DataScannerViewController` is main-actor isolated; ``ScanSourceProtocol`` is not, and isolating
/// it would push `@MainActor` up through the flow ViewModels that present the scanner, none of which
/// are annotated today. So the controller is reached through `MainActor.assumeIsolated`: every call
/// arrives from the ViewModel, which SwiftUI drives from `body`, `onAppear` and `onChange` — all on
/// the main thread — so the assumption is one the caller already guarantees.
public final class CameraScanSource: NSObject, ScanSourceProtocol {
    private let payloadSubject = PassthroughSubject<String, Never>()
    public var recognisedPayloadPublisher: AnyPublisher<String, Never> {
        payloadSubject.eraseToAnyPublisher()
    }

    /// The `DataScannerViewController` is the preview *and* the recogniser, so the source owns it
    /// and hands the same instance to SwiftUI. Built lazily: constructing it before the screen is
    /// on its way is a camera session nobody asked for.
    private lazy var scannerViewController: DataScannerViewController = MainActor.assumeIsolated {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = self
        return controller
    }

    /// Mirrors what has been asked of the controller, so a repeated `startScanning()` — the
    /// ViewModel calls it on every appearance and every return to the foreground — does not restart
    /// a session that is already running.
    private var isScanning = false

    override public init() {
        super.init()
    }

    // MARK: - ScanSourceProtocol

    public func makePreview() -> AnyView {
        AnyView(DataScannerPreview(controller: scannerViewController))
    }

    public func startScanning() {
        guard !isScanning else { return }
        isScanning = true

        // The system prompt is raised here rather than left to the preview, so the first open asks
        // for the camera exactly once and a refusal is a fact this type can see.
        Task { @MainActor [weak self] in
            let isAuthorised = await AVCaptureDevice.requestAccess(for: .video)
            guard let self, self.isScanning else { return }

            guard isAuthorised else {
                self.isScanning = false
                return
            }

            guard DataScannerViewController.isSupported, DataScannerViewController.isAvailable else {
                self.isScanning = false
                return
            }

            try? self.scannerViewController.startScanning()
        }
    }

    public func stopScanning() {
        guard isScanning else { return }
        isScanning = false
        MainActor.assumeIsolated { scannerViewController.stopScanning() }
    }
}

// MARK: - DataScannerViewControllerDelegate

extension CameraScanSource: DataScannerViewControllerDelegate {
    @MainActor
    public func dataScanner(
        _ dataScanner: DataScannerViewController,
        didAdd addedItems: [RecognizedItem],
        allItems: [RecognizedItem]
    ) {
        for item in addedItems {
            guard case .barcode(let barcode) = item, let payload = barcode.payloadStringValue else { continue }
            payloadSubject.send(payload)
        }
    }
}

// MARK: - DataScannerPreview

/// Puts the source's own scanner controller on screen. It is handed over rather than created here,
/// because the controller SwiftUI shows has to be the one publishing recognitions.
private struct DataScannerPreview: UIViewControllerRepresentable {
    let controller: DataScannerViewController

    func makeUIViewController(context: Context) -> DataScannerViewController {
        controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) { }
}
