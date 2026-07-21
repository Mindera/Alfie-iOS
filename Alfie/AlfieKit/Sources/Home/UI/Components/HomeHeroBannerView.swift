import Model
import SharedUI
import SwiftUI

/// A single full-bleed hero slide: image + bottom scrim + overlay title + underlined CTA.
struct HomeHeroBannerView: View {
    private enum Constants {
        static let aspectRatio: CGFloat = 375.0 / 500.0
        static let scrimOpacity: CGFloat = 0.5
        static let scrimEndLocation: CGFloat = 0.52
    }

    private let banner: HomeHeroBanner
    private let onTapCTA: () -> Void

    init(banner: HomeHeroBanner, onTapCTA: @escaping () -> Void = {}) {
        self.banner = banner
        self.onTapCTA = onTapCTA
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(banner.imageName, bundle: .module)
                .resizable()
                .scaledToFill()

            LinearGradient(
                stops: [
                    .init(color: Theme.contentContentPrimary.opacity(Constants.scrimOpacity), location: 0),
                    .init(color: .clear, location: Constants.scrimEndLocation),
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing24) {
                Text.build(theme.font.display.medium(banner.title))
                    .foregroundStyle(Theme.contentContentInvertedPrimary)
                    .multilineTextAlignment(.leading)

                Button(action: onTapCTA) {
                    Text.build(theme.font.link.medium(banner.ctaTitle, underline: true))
                        .foregroundStyle(Theme.contentContentInvertedPrimary)
                }
                .accessibilityIdentifier(AccessibilityID.cta)
            }
            .padding(Primitives.Spacing.spacing16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .aspectRatio(Constants.aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

private enum AccessibilityID {
    static let cta = "hero-cta"
}

#if DEBUG
#Preview {
    HomeHeroBannerView(banner: HomeHeroBanner.placeholders[0])
}
#endif
