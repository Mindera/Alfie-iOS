import AVFoundation
import Combine
import Model
import SwiftUI
import VisionKit

/// The real camera, via VisionKit's `DataScannerViewController`.
///
/// Only QR codes are recognised: the Alfie code is a QR code, and reading the manufacturer's
/// Barcode is a separate ticket that will widen this list. Everything the scanner sees is published
/// verbatim — deciding what a payload means belongs to `ScannerViewModel`.
///
/// A device that cannot scan, and a shopper who has refused the camera, both currently end at a
/// preview that never recognises anything. Explaining that to them is the follow-up ticket for
/// failure states.
///
/// `DataScannerViewController` is main-actor isolated; ``CameraScanServiceProtocol`` is not, and
/// isolating it would push `@MainActor` up through the flow ViewModels that present the scanner,
/// none of which are annotated today. So the controller is reached through `MainActor.assumeIsolated`:
/// every call arrives from the ViewModel, which SwiftUI drives from `body`, `onAppear` and
/// `onChange` — all on the main thread — so the assumption is one the caller already guarantees.
public final class CameraScanService: NSObject, CameraScanServiceProtocol {
    private let payloadSubject = PassthroughSubject<String, Never>()
    public var recognisedPayloadPublisher: AnyPublisher<String, Never> {
        payloadSubject.eraseToAnyPublisher()
    }

    /// Built on first use rather than in `init`: constructing it opens a camera session, and the
    /// service is created before the screen it belongs to is on its way. Held as an optional so
    /// `stopScanning()` can decline to build one just to stop it.
    private var controller: DataScannerViewController?

    /// What the ViewModel has asked for, which is not the same as what the camera is doing —
    /// authorisation can refuse. Keeping the two apart means a refusal does not read as "stopped on
    /// request", so a later appearance asks again instead of assuming a session is already running.
    private var isStartRequested = false

    /// Tells one start request from the next. The system permission alert drives the app inactive,
    /// so stop-then-start around it is the ordinary first-run path, not an edge case; without this
    /// token both requests would resume past the `await` and start the controller twice.
    private var startToken = 0

    override public init() {
        super.init()
    }

    deinit {
        // The controller holds the camera, so releasing this service has to release that too — the
        // screen may have gone away without a matching `stopScanning()`.
        guard let controller else { return }
        Task { @MainActor in controller.stopScanning() }
    }

    // MARK: - CameraScanServiceProtocol

    public func makePreview() -> AnyView {
        MainActor.assumeIsolated { AnyView(DataScannerPreview(controller: makeControllerIfNeeded())) }
    }

    public func startScanning() {
        MainActor.assumeIsolated {
            guard !isStartRequested else { return }
            isStartRequested = true
            startToken &+= 1
            let token = startToken

            // The system prompt is raised here rather than left to the preview, so the first open
            // asks for the camera exactly once and a refusal is a fact this type can see.
            Task { @MainActor [weak self] in
                let isAuthorised = await AVCaptureDevice.requestAccess(for: .video)
                guard let self, self.startToken == token, self.isStartRequested else { return }

                guard
                    isAuthorised,
                    DataScannerViewController.isSupported,
                    DataScannerViewController.isAvailable
                else {
                    // Not scanning, and not by request — let a later appearance try again.
                    self.isStartRequested = false
                    return
                }

                try? self.makeControllerIfNeeded().startScanning()
            }
        }
    }

    public func stopScanning() {
        MainActor.assumeIsolated {
            guard isStartRequested else { return }
            isStartRequested = false
            // Invalidates any start still waiting on the authorisation prompt.
            startToken &+= 1
            controller?.stopScanning()
        }
    }

    // MARK: - Private

    @MainActor
    private func makeControllerIfNeeded() -> DataScannerViewController {
        if let controller {
            return controller
        }

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
        self.controller = controller
        return controller
    }
}

// MARK: - DataScannerViewControllerDelegate

extension CameraScanService: DataScannerViewControllerDelegate {
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

/// Puts the service's own scanner controller on screen. It is handed over rather than created here,
/// because the controller SwiftUI shows has to be the one publishing recognitions.
private struct DataScannerPreview: UIViewControllerRepresentable {
    let controller: DataScannerViewController

    func makeUIViewController(context: Context) -> DataScannerViewController {
        controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) { }
}
