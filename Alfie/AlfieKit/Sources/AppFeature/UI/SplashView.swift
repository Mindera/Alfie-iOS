import AccessibilityIdentifiers
import SharedUI
import SwiftUI

/// App startup / splash screen: the MINDERA/ALFIE wordmark centred above a static loading
/// indicator, on the design-system background. Shown while the app resolves its startup state.
struct SplashView: View {
    private enum Constants {
        static let wordmarkWidth: CGFloat = 160
    }

    var body: some View {
        VStack(spacing: theme.spacing.space200) {
            // Invisible mirror of the spinner reserves matching space above the wordmark,
            // keeping the wordmark at the screen's vertical centre — so it lines up with the
            // launch screen and doesn't jump up when the spinner appears.
            ThemedSpinnerView()
                .hidden()

            Image(ThemedImage.splashLogo.literalName, bundle: ThemedImage.splashLogo.bundle)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.wordmarkWidth)

            ThemedSpinnerView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.color.neutrals0)
        .accessibilityIdentifier(AccessibilityID.Splash.screen)
    }
}

#Preview {
    SplashView()
}
