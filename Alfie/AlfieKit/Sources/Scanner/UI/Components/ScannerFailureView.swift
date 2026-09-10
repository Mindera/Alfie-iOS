import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI

/// What the scanner shows when there is no camera to look through.
///
/// It replaces the preview rather than sitting over it, because each of these cases means there is
/// nothing behind it: a blank rectangle where a camera should be is the thing this screen exists to
/// avoid. Only a refused camera offers a way out, and it leads out of the app — the other two are
/// facts about the device, not choices the shopper can revisit.
struct ScannerFailureView: View {
    let error: ScannerViewErrorType
    let openSettings: () -> Void

    var body: some View {
        ErrorView(title: title, message: message, buttons: buttons)
            .accessibilityIdentifier(AccessibilityID.Scanner.failure)
    }

    private var title: String? {
        switch error {
        case .cameraPermissionDenied:
            return L10n.Scanner.Error.PermissionDenied.title

        case .deviceNotSupported, .generic:
            // No title: neither has a headline that says more than its message already does, and an
            // invented one would be noise for a shopper reading the screen aloud.
            return nil
        }
    }

    private var message: String {
        switch error {
        case .cameraPermissionDenied:
            return L10n.Scanner.Error.PermissionDenied.message

        case .deviceNotSupported:
            return L10n.Scanner.Error.Unsupported.message

        case .generic:
            return L10n.Scanner.Error.Generic.message
        }
    }

    private var buttons: [ErrorView.ButtonConfiguration] {
        guard case .cameraPermissionDenied = error else { return [] }
        return [
            .init(
                cta: L10n.Scanner.Error.PermissionDenied.action,
                accessibilityId: AccessibilityID.Scanner.openSettings,
                action: openSettings
            ),
        ]
    }
}

#if DEBUG
#Preview {
    VStack {
        ScannerFailureView(error: .cameraPermissionDenied, openSettings: { })
        ScannerFailureView(error: .deviceNotSupported, openSettings: { })
    }
}
#endif
