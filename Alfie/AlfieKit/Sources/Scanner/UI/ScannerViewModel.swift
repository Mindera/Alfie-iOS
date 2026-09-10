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
/// between a scan that failed and a camera that cannot run. A code that opens nothing in Alfie is
/// the first: the camera keeps running underneath a notice, because the fix is the next tag along.
/// A refused or missing camera is the second: it replaces the screen, because there is no scan to
/// retry until something outside this app changes — which is why every start clears whatever the
/// last one said.
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
    private var hasOpenedLink = false
    private var isScanning = false
    /// Numbers the notices, so that the same words said twice are two notices rather than one. See
    /// ``ScannerNotice``.
    private var noticeCount = 0
    private var subscriptions = Set<AnyCancellable>()

    public var title: String { L10n.Scanner.title }
    public var preview: AnyView { scanService.makePreview() }
    @Published public private(set) var state: ViewState<ScannerViewStateModel, ScannerViewErrorType> = initialState

    /// What the screen shows whenever a scan is starting: the guidance, and nothing said yet about
    /// a code. Named once, because a start after a failure has to arrive at exactly the state a
    /// first start does.
    private static var initialState: ViewState<ScannerViewStateModel, ScannerViewErrorType> {
        .success(.init(guidance: L10n.Scanner.Guidance.message))
    }

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
        scanService.recognisedPayloadsPublisher
            .sink { [weak self] in self?.didRecognise(payloads: $0) }
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
        // The service has already cleared its own start request — nothing is running, and not
        // because anyone asked it to stop — so this has to agree with it. Left `true`, the next
        // `updateScanning()` would believe a camera was already running and decline to start one.
        isScanning = false
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
        let shouldScan = isOnScreen && isAppActive && !hasOpenedLink
        guard shouldScan != isScanning else { return }
        isScanning = shouldScan

        if shouldScan {
            // Every start is a fresh attempt, so it starts from a fresh screen: an explanation left
            // over from the last one would outlive the camera access the shopper has just granted
            // in Settings, and a notice would outlive the code it was about.
            state = Self.initialState
            scanService.startScanning()
        } else {
            scanService.stopScanning()
        }
    }

    /// Acts on one code per frame, and on the one the shopper meant. A Swing tag prints the Barcode
    /// beside the Alfie code, so both are routinely read at once; ``ScannedCode/precedence`` is what
    /// settles which is answered.
    ///
    /// Neither thing said here goes near the network. A code that is not ours is not looked up
    /// because nothing in Alfie answers to it, and a Barcode is not looked up because nothing *can*
    /// — the credentials to resolve one do not exist, which is the reason Alfie prints its own code
    /// (ADR-0001). Both are said over a camera that keeps running: the shopper is standing at the
    /// rail, and the fix is the next code along.
    private func didRecognise(payloads: [String]) {
        guard !hasOpenedLink else { return }

        switch payloads.map(classify(payload:)).actionable {
        case .alfieCode(let url):
            open(url)

        case .barcode(let value):
            log.debug("Scanned the manufacturer's Barcode, which Alfie cannot resolve: \(value)")
            analytics.trackScanFailed(reason: .barcode)
            show(notice: L10n.Scanner.BarcodeDetected.message)

        case .unrecognised(let payload):
            log.debug("Scanned code opens nothing in Alfie: \(payload)")
            analytics.trackScanFailed(reason: .unrecognised)
            show(notice: L10n.Scanner.Unrecognised.message)

        case .none:
            break
        }
    }

    /// The deep-link service is asked what the code is, not asked to open it: classifying the
    /// payload is the scanner's job — a code that opens nothing must leave the camera running —
    /// while opening the page belongs to the flow.
    ///
    /// Tried as an Alfie link first, so the one code that is worth resolving is never mistaken for
    /// one of the two that are not.
    private func classify(payload: String) -> ScannedCode {
        if let url = URL(string: payload), opensInApp(deepLinkService.deepLinkType(url)) {
            return .alfieCode(url)
        }

        if ScannedCode.isBarcode(payload) {
            return .barcode(value: payload)
        }

        return .unrecognised(payload: payload)
    }

    private func open(_ url: URL) {
        hasOpenedLink = true
        updateScanning()
        // Dismissed before the product opens, not left behind it: the deep-link path pushes onto a
        // tab that the scanner is covering.
        close()
        openScannedLink(url)
    }

    /// Whether a scanned link reaches somewhere in the app.
    ///
    /// An Alfie code carries an Alfie link and the flow's deep-link path decides where it lands, so
    /// anything that path can reach counts as recognised — not only a Product. Judging it on
    /// ``DeepLink/LinkType/productDetail`` alone would tell a shopper holding a real Alfie code that
    /// it "isn't from Alfie", which is both false and unhelpful.
    ///
    /// The three that reach nothing are the notice cases: `nil` and
    /// ``DeepLink/LinkType/unknown`` are not our links at all, and ``DeepLink/LinkType/webView`` is
    /// the fallback that would open the blank web view this screen exists to prevent. Switched
    /// exhaustively on purpose, so a new link type has to decide which side it is on.
    private func opensInApp(_ linkType: DeepLink.LinkType?) -> Bool {
        switch linkType {
        case .none, .unknown, .webView:
            return false
        case .home, .shop, .bag, .wishlist, .account, .productList, .productDetail:
            return true
        }
    }
}
