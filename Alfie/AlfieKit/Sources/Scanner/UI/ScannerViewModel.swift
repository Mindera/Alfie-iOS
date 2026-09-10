import AlicerceLogging
import Combine
import Model
import SharedUI
import SwiftUI

/// Turns a recognised code into a page.
///
/// The scanner deliberately owns no navigation of its own: an Alfie code carries an Alfie link, so
/// the code is handed to the deep-link path the app already uses for a tapped link, and that path
/// decides where it lands (see ADR-0001). The Product opens on its default Variant — the SKU the
/// code carries is parsed and ignored until Variant preselection is implemented.
public final class ScannerViewModel: ScannerViewModelProtocol {
    private let scanSource: ScanSourceProtocol
    private let deepLinkService: DeepLinkServiceProtocol
    private let close: () -> Void
    private let log: Logger

    /// Recognition runs only while the screen is both in front of the shopper and in a foreground
    /// app. Kept as two facts rather than one flag because they change independently — a scanner
    /// covered by a pushed page is not the same thing as a backgrounded app.
    private var isOnScreen = false
    private var isAppActive = true
    /// One scan opens one page. Set the moment a code is accepted, so a second recognition of the
    /// same tag — and any recognition after the screen goes away to make room for the product —
    /// finds the decision already made.
    private var hasOpenedProduct = false
    private var isScanning = false
    private var subscriptions = Set<AnyCancellable>()

    public var title: String { L10n.Scanner.title }
    public var guidance: String { L10n.Scanner.Guidance.message }
    public var preview: AnyView { scanSource.makePreview() }

    public init(dependencies: ScannerDependencyContainer, close: @escaping () -> Void) {
        self.scanSource = dependencies.makeScanSource()
        self.deepLinkService = dependencies.deepLinkService
        self.log = dependencies.log
        self.close = close

        setupBindings()
    }

    private func setupBindings() {
        scanSource.recognisedPayloadPublisher
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
            scanSource.startScanning()
        } else {
            scanSource.stopScanning()
        }
    }

    /// A code only opens a page if the deep-link path resolves it to a Product. Anything else — a
    /// manufacturer Barcode, a poster's QR code, a colleague's Wi-Fi — leaves the scanner running,
    /// so the shopper can point the camera at the right tag without reopening the screen. Telling
    /// them *why* nothing happened is a separate ticket.
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
        close()
        deepLinkService.openUrls([url])
    }
}
