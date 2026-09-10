import AlicerceLogging
import Combine
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
public final class ScannerViewModel: ScannerViewModelProtocol {
    private let scanService: CameraScanServiceProtocol
    private let deepLinkService: DeepLinkServiceProtocol
    private let openScannedLink: (URL) -> Void
    private let close: () -> Void
    private let log: Logger

    private var isOnScreen = false
    private var isAppActive = true
    private var hasOpenedProduct = false
    private var isScanning = false
    private var subscriptions = Set<AnyCancellable>()

    public var title: String { L10n.Scanner.title }
    public var guidance: String { L10n.Scanner.Guidance.message }
    public var preview: AnyView { scanService.makePreview() }

    public init(
        dependencies: ScannerDependencyContainer,
        openScannedLink: @escaping (URL) -> Void,
        close: @escaping () -> Void
    ) {
        self.scanService = dependencies.makeScanService()
        self.deepLinkService = dependencies.deepLinkService
        self.log = dependencies.log
        self.openScannedLink = openScannedLink
        self.close = close
        setupBindings()
    }

    private func setupBindings() {
        scanService.recognisedPayloadPublisher
            .sink { [weak self] in self?.didRecognise(payload: $0) }
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

    // MARK: - Private

    private func updateScanning() {
        let shouldScan = isOnScreen && isAppActive && !hasOpenedProduct
        guard shouldScan != isScanning else { return }
        isScanning = shouldScan

        if shouldScan {
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
            log.debug("Scanned code is not an Alfie code, ignoring: \(payload)")
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
