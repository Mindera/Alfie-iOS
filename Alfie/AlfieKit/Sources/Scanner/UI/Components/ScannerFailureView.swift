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
        ErrorView(title: copy.title, message: copy.message, buttons: buttons)
            .accessibilityIdentifier(AccessibilityID.Scanner.failure)
    }

    /// Everything the screen says about one failure, decided in one place. Whether a case has a
    /// title and whether it has a way out are part of what that case *is*, so they are answered
    /// together rather than by three switches that could disagree.
    private struct Copy {
        /// Absent where a headline would say no more than the message already does, and an invented
        /// one would be noise for a shopper reading the screen aloud.
        let title: String?
        let message: String
        /// Absent where there is nothing the shopper can do about it.
        let action: String?
    }

    private var copy: Copy {
        switch error {
        case .cameraPermissionDenied:
            return .init(
                title: L10n.Scanner.Error.PermissionDenied.title,
                message: L10n.Scanner.Error.PermissionDenied.message,
                action: L10n.Scanner.Error.PermissionDenied.action
            )

        case .deviceNotSupported:
            return .init(title: nil, message: L10n.Scanner.Error.Unsupported.message, action: nil)

        case .generic:
            return .init(title: nil, message: L10n.Scanner.Error.Generic.message, action: nil)
        }
    }

    private var buttons: [ErrorView.ButtonConfiguration] {
        guard let action = copy.action else { return [] }
        return [
            .init(
                cta: action,
                accessibilityId: AccessibilityID.Scanner.openSettings,
                action: openSettings
            ),
        ]
    }
}

#if DEBUG
#Preview("Permission denied") {
    ScannerFailureView(error: .cameraPermissionDenied, openSettings: { })
}

#Preview("Device not supported") {
    ScannerFailureView(error: .deviceNotSupported, openSettings: { })
}

#Preview("Generic") {
    ScannerFailureView(error: .generic, openSettings: { })
}
#endif
