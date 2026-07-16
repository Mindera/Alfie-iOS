import AccessibilityIdentifiers
import SharedUI
import SwiftUI

/// App startup splash: the MINDERA/ALFIE wordmark above the loading spinner.
struct SplashView: View {
    private enum Constants {
        static let wordmarkWidth: CGFloat = 160
    }

    var body: some View {
        Image(ThemedImage.splashLogo.literalName, bundle: ThemedImage.splashLogo.bundle)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.wordmarkWidth)
            // Spinner hangs below the wordmark without affecting its centring (aligns with launch screen).
            .overlay(alignment: .bottom) {
                ThemedSpinnerView()
                    .alignmentGuide(.bottom) { $0[.top] - theme.spacing.space200 }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { theme.color.neutrals0.ignoresSafeArea() }
            .accessibilityIdentifier(AccessibilityID.Splash.screen)
    }
}

#Preview {
    SplashView()
}
