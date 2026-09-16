import AccessibilityIdentifiers
import SharedUI
import SwiftUI

/// App startup splash: the SELFRIDGES&Co wordmark over the brand campaign image.
/// Public so the app target can paint it before the view model exists, otherwise the
/// launch screen crossfades out onto an empty white window.
public struct SplashView: View {
    private enum Constants {
        static let scrimOpacity = 0.3
    }

    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        ZStack {
            // Each layer ignores the safe area itself: clipping one first leaves the expanded edge unpainted.
            Image(ThemedImage.splashBackground.literalName, bundle: ThemedImage.splashBackground.bundle)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Keeps the wordmark legible wherever the photo runs light.
            theme.color.neutrals900
                .opacity(Constants.scrimOpacity)
                .ignoresSafeArea()

            Image(ThemedImage.brandWordmark.literalName, bundle: ThemedImage.brandWordmark.bundle)
                // Spinner hangs below the wordmark without affecting its centring (aligns with launch screen).
                .overlay(alignment: .bottom) {
                    LoadingSpinner()
                        .alignmentGuide(.bottom) { $0[.top] - theme.spacing.space200 }
                }
                .foregroundStyle(theme.color.neutrals0)
        }
        .accessibilityIdentifier(AccessibilityID.Splash.screen)
    }
}

#Preview {
    SplashView()
}
