import AccessibilityIdentifiers
import SharedUI
import SwiftUI

/// App startup splash: the MINDERA/ALFIE wordmark above the loading spinner.
struct SplashView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Image(ThemedImage.splashLogo.literalName, bundle: ThemedImage.splashLogo.bundle)
            // Spinner hangs below the wordmark without affecting its centring (aligns with launch screen).
            .overlay(alignment: .bottom) {
                LoadingSpinner()
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
