import AccessibilityIdentifiers
import SharedUI
import SwiftUI

/// App startup splash: the MINDERA/ALFIE wordmark above the loading spinner.
struct SplashView: View {
    private enum Constants {
        static let wordmarkWidth: CGFloat = 160
    }

    var body: some View {
        VStack(spacing: theme.spacing.space200) {
            // Mirrors the spinner so the wordmark stays centred, aligned with the launch screen.
            ThemedSpinnerView()
                .hidden()

            Image(ThemedImage.splashLogo.literalName, bundle: ThemedImage.splashLogo.bundle)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.wordmarkWidth)

            ThemedSpinnerView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Bleed the background full-screen; content stays in the safe area.
        .background { theme.color.neutrals0.ignoresSafeArea() }
        .accessibilityIdentifier(AccessibilityID.Splash.screen)
    }
}

#Preview {
    SplashView()
}
