import Model
import SwiftUI
import Utils

/// How a tab puts the scanner on screen.
///
/// Every tab with a Search bar builds the scanner from the same decisions — whether to explain the
/// camera first, where a recognised link goes, the one recovery a refused camera has is the door out
/// to Settings, and closing clears the tab's overlay. Held here rather than in each flow so that a
/// second tab gaining a Scan control is one call, not another copy of them.
///
/// Only the overlay transitions differ between callers, which is why they are the only closures left
/// to them: only the tab knows what it is covering.
public enum ScannerPresentation {
    /// Whether tapping Scan should first explain why the camera is needed. Only until iOS has asked:
    /// after that the system decision stands, and a refusal is handled inside the scanner.
    public static func needsIntro(dependencies: ScannerDependencyContainer) -> Bool {
        dependencies.isCameraAccessUndetermined()
    }

    public static func makeIntroView(onContinue: @escaping () -> Void, onNotNow: @escaping () -> Void) -> some View {
        ScannerIntroView(onContinue: onContinue, onNotNow: onNotNow)
    }

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
            openScannedLink: { deepLinkService.openUrls([$0]) },
            // A refused camera can only be granted outside the app, so the one recovery the scanner
            // can offer is the door out to Settings.
            openAppSettings: { ExternalAppLauncher.openAppSettings() },
            close: close
        )
    }
}
