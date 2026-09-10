import AlicerceLogging
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
/// A device that cannot scan, and a shopper who has refused the camera, are both reported through
/// ``failurePublisher`` rather than left at a preview that never recognises anything — and the
/// capability check comes first, so a device that cannot scan is never asked for a camera it has no
/// use for.
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

    private let failureSubject = PassthroughSubject<CameraScanFailure, Never>()
    public var failurePublisher: AnyPublisher<CameraScanFailure, Never> {
        failureSubject.eraseToAnyPublisher()
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

    private let log: Logger
    private let isDeviceSupported: @MainActor () -> Bool
    private let isScanningAvailable: @MainActor () -> Bool
    private let requestCameraAccess: @MainActor () async -> Bool

    /// The two capability checks and the authorisation prompt are injected so that the order they
    /// run in — hardware first, prompt only if the hardware can use it — is a fact a test can
    /// assert on a simulator that has neither. Their defaults are the real ones; nothing but a test
    /// passes anything else.
    public init(
        log: Logger,
        isDeviceSupported: @escaping @MainActor () -> Bool = { DataScannerViewController.isSupported },
        isScanningAvailable: @escaping @MainActor () -> Bool = { DataScannerViewController.isAvailable },
        requestCameraAccess: @escaping @MainActor () async -> Bool = {
            await AVCaptureDevice.requestAccess(for: .video)
        }
    ) {
        self.log = log
        self.isDeviceSupported = isDeviceSupported
        self.isScanningAvailable = isScanningAvailable
        self.requestCameraAccess = requestCameraAccess
        super.init()
    }

    deinit {
        // The controller holds the camera, so releasing this service has to release that too — the
        // screen may have gone away without a matching `stopScanning()`.
        //
        // `controller` is written only on the main actor, and this is the one read that happens off
        // it. It is safe for a reason `deinit` alone provides: the last reference has already gone,
        // so no other code can be touching the property while this runs.
        guard let controller else { return }
        Task { @MainActor in controller.stopScanning() }
    }

    // MARK: - CameraScanServiceProtocol

    public func makePreview() -> AnyView {
        MainActor.assumeIsolated {
            // The screen asks for a preview before it has been told there is nothing to preview: the
            // first `body` runs ahead of the `onAppear` that starts scanning. On a device that cannot
            // scan that would build a scanner controller for the one frame before the explanation
            // replaces it, so the check is repeated here rather than assumed.
            guard isDeviceSupported() else { return AnyView(EmptyView()) }
            return AnyView(DataScannerPreview(controller: makeControllerIfNeeded()))
        }
    }

    public func startScanning() {
        MainActor.assumeIsolated {
            guard !isStartRequested else { return }
            isStartRequested = true
            startToken &+= 1
            let token = startToken

            // Before the prompt, not after: a device that cannot do live data scanning has no use
            // for camera access, so asking for it would cost the shopper an answer and buy them a
            // scanner that still does not work.
            guard isDeviceSupported() else {
                return fail(with: .deviceNotSupported)
            }

            // The system prompt is raised here rather than left to the preview, so the first open
            // asks for the camera exactly once and a refusal is a fact this type can see.
            Task { @MainActor [weak self] in
                guard let requestCameraAccess = self?.requestCameraAccess else { return }
                let isAuthorised = await requestCameraAccess()
                guard let self, self.startToken == token, self.isStartRequested else { return }

                guard isAuthorised else {
                    return self.fail(with: .permissionDenied)
                }

                guard self.isScanningAvailable() else {
                    return self.fail(with: .unavailable)
                }

                do {
                    try self.makeControllerIfNeeded().startScanning()
                } catch {
                    self.log.error("Camera scanning failed to start: \(error)")
                    self.fail(with: .unavailable)
                }
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

    /// Reports why nothing is scanning, and clears the request that produced it: nothing is running,
    /// and not because anyone asked it to stop, so a later appearance has to be free to try again —
    /// the shopper may have granted the camera in Settings in between.
    @MainActor
    private func fail(with failure: CameraScanFailure) {
        isStartRequested = false
        failureSubject.send(failure)
    }

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
