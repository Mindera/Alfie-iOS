import AlicerceLogging
import Combine
import Core
import Model
import SharedUI
import SwiftUI

/// Turns a recognised code into a page.
///
/// The scanner deliberately owns no navigation of its own. An Alfie code carries an Alfie link, so
/// a recognised code is handed back to the flow, which passes it to the deep-link path the app
/// already uses for a tapped link, and that path decides where it lands. ADR-0001 is what makes
/// this possible: it puts the Handle inside the code, so there is nothing to look up and no new
/// route to add. The Product opens on its default Variant — the SKU the code carries is parsed and
/// ignored until Variant preselection is implemented.
///
/// It does own what the shopper is told when that does not happen, and the distinction it draws is
/// between a scan that failed and a camera that cannot run. A code that is not ours is the first:
/// the camera keeps running underneath a notice, because the fix is the next tag along. A refused
/// or missing camera is the second: it replaces the screen, because there is no scan to retry until
/// something outside this app changes — which is why every start clears whatever the last one said.
public final class ScannerViewModel: ScannerViewModelProtocol {
    private let scanService: CameraScanServiceProtocol
    private let deepLinkService: DeepLinkServiceProtocol
    private let analytics: AlfieAnalyticsTracker
    private let openScannedLink: (URL) -> Void
    private let openAppSettings: () -> Void
    private let close: () -> Void
    private let log: Logger

    private var isOnScreen = false
    private var isAppActive = true
    private var hasOpenedProduct = false
    private var isScanning = false
    /// Numbers the notices, so that the same words said twice are two notices rather than one. See
    /// ``ScannerNotice``.
    private var noticeCount = 0
    private var subscriptions = Set<AnyCancellable>()

    public var title: String { L10n.Scanner.title }
    public var preview: AnyView { scanService.makePreview() }
    @Published public private(set) var state: ViewState<ScannerViewStateModel, ScannerViewErrorType>
        = .success(.init(guidance: L10n.Scanner.Guidance.message))

    /// `openAppSettings` arrives as a closure from the flow, like `openScannedLink` and `close`:
    /// everything that takes the shopper off this screen — including out of the app entirely —
    /// leaves through the same seam, rather than half of it through the dependency container.
    public init(
        dependencies: ScannerDependencyContainer,
        openScannedLink: @escaping (URL) -> Void,
        openAppSettings: @escaping () -> Void,
        close: @escaping () -> Void
    ) {
        self.scanService = dependencies.makeScanService()
        self.deepLinkService = dependencies.deepLinkService
        self.analytics = dependencies.analytics
        self.log = dependencies.log
        self.openScannedLink = openScannedLink
        self.openAppSettings = openAppSettings
        self.close = close
        setupBindings()
    }

    private func setupBindings() {
        scanService.recognisedPayloadPublisher
            .sink { [weak self] in self?.didRecognise(payload: $0) }
            .store(in: &subscriptions)

        scanService.failurePublisher
            .sink { [weak self] in self?.didFailToScan(with: $0) }
            .store(in: &subscriptions)
    }

    // MARK: - ScannerViewModelProtocol

    public func viewDidAppear() {
        isOnScreen = true
        updateScanning()
    }

    public func viewDidDisappear() {
        isOnScreen = false
        updateScanning()
    }

    public func didChangeScenePhase(isActive: Bool) {
        isAppActive = isActive
        updateScanning()
    }

    public func didTapClose() {
        close()
    }

    public func didDismissNotice() {
        guard let model = state.value else { return }
        state = .success(model.with(notice: nil))
    }

    public func didTapOpenSettings() {
        openAppSettings()
    }

    // MARK: - Private

    private func didFailToScan(with failure: CameraScanFailure) {
        log.error("Camera scanning is unavailable: \(failure)")
        let error = ScannerViewErrorType.from(failure: failure)
        analytics.trackScanFailed(reason: error.analyticsReason)
        // Replaces the whole state rather than joining it: there is no camera behind this, so the
        // guidance about what to point one at has nothing left to describe.
        state = .error(error)
    }

    /// A notice only exists over a running camera, so it is written into the success state rather
    /// than replacing it — an error state has no guidance to put it beside. Each one is numbered,
    /// so that a repeat is a new notice and gets announced again.
    private func show(notice message: String) {
        guard let model = state.value else { return }
        noticeCount += 1
        state = .success(model.with(notice: .init(id: noticeCount, message: message)))
    }

    private func updateScanning() {
        let shouldScan = isOnScreen && isAppActive && !hasOpenedProduct
        guard shouldScan != isScanning else { return }
        isScanning = shouldScan

        if shouldScan {
            // Every start is a fresh attempt, so it starts from a fresh screen: an explanation left
            // over from the last one would outlive the camera access the shopper has just granted
            // in Settings, and a notice would outlive the code it was about.
            state = .success(.init(guidance: L10n.Scanner.Guidance.message))
            scanService.startScanning()
        } else {
            scanService.stopScanning()
        }
    }

    /// The deep-link service is asked what the code is, not asked to open it: classifying the
    /// payload is the scanner's job — an unrecognised code must leave the camera running — while
    /// opening the page belongs to the flow.
    private func didRecognise(payload: String) {
        guard !hasOpenedProduct else { return }

        guard
            let url = URL(string: payload),
            case .productDetail = deepLinkService.deepLinkType(url)
        else {
            log.debug("Scanned code is not an Alfie code: \(payload)")
            analytics.trackScanFailed(reason: .unrecognised)
            // Said over the camera rather than instead of it: the shopper is standing in front of
            // the rail and the next tag is the fix, so the scanner has to still be running when
            // they find it.
            show(notice: L10n.Scanner.Unrecognised.message)
            return
        }

        hasOpenedProduct = true
        updateScanning()
        // Dismissed before the product opens, not left behind it: the deep-link path pushes onto a
        // tab that the scanner is covering.
        close()
        openScannedLink(url)
    }
}
