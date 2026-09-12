import Model
import Utils

/// How a tab puts the scanner on screen.
///
/// Every tab with a Search bar builds the scanner from the same three decisions — a recognised link
/// goes to the deep-link path, the one recovery a refused camera has is the door out to Settings,
/// and closing clears the tab's overlay. Held here rather than in each flow so that a second tab
/// gaining a Scan control is one call, not another copy of them.
///
/// Only `close` differs between callers, which is why it is the only closure left to them: it is the
/// one decision that is genuinely the tab's, because only the tab knows what it is covering.
public enum ScannerPresentation {
    /// A fresh ViewModel — and so a fresh camera session — for each presentation.
    ///
    /// `close` is expected to clear the caller's overlay as well as dismiss the screen: a successful
    /// scan hands over to the deep-link path, which clears the tab's overlay itself, and the flow
    /// would otherwise still believe the scanner was up and refuse to present it a second time.
    public static func makeViewModel(
        dependencies: ScannerDependencyContainer,
        source: ScanEntryPoint,
        close: @escaping () -> Void
    ) -> ScannerViewModel {
        // The container's own service, not a second one handed in beside it: the scanner already
        // asks this service what a code is, and asking one service what a link means while handing
        // it to another to open is a distinction with no difference.
        let deepLinkService = dependencies.deepLinkService

        return ScannerViewModel(
            dependencies: dependencies,
            source: source,
            // Captured directly rather than through the flow: the scanner still decides nothing
            // about navigation — it hands the URL over the same seam as before — and routing the
            // hand-off through the flow only to reach a service the flow does not otherwise use
            // made every tab carry a reference for this one line.
            openScannedLink: { deepLinkService.openUrls([$0]) },
            // A refused camera can only be granted outside the app, so the one recovery the scanner
            // can offer is the door out to Settings.
            openAppSettings: { ExternalAppLauncher.openAppSettings() },
            close: close
        )
    }
}
