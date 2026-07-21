import Model
import SharedUI
import SwiftUI

/// A single full-bleed hero slide: image + bottom scrim + overlay (title, CTA, page dots), bottom-left.
struct HomeHeroBannerView: View {
    private enum Constants {
        static let scrimOpacity: CGFloat = 0.5
        static let scrimEndLocation: CGFloat = 0.52
        static let activeDotSize = CGSize(width: 12, height: 6)
        static let inactiveDotDiameter: CGFloat = 6
        static let inactiveDotOpacity: CGFloat = 0.4
    }

    private let banner: HomeHeroBanner
    private let pageCount: Int
    private let currentIndex: Int
    private let size: CGSize
    private let onTapCTA: () -> Void

    init(
        banner: HomeHeroBanner,
        pageCount: Int = 1,
        currentIndex: Int = 0,
        size: CGSize = CGSize(width: 375, height: 500),
        onTapCTA: @escaping () -> Void = {}
    ) {
        self.banner = banner
        self.pageCount = pageCount
        self.currentIndex = currentIndex
        self.size = size
        self.onTapCTA = onTapCTA
    }

    var body: some View {
        // Explicit page-sized frame + clip first, so the image can't grow past the page and the
        // bottom-left overlay (title, CTA, dots) always stays inside the visible bounds.
        Image(banner.imageName, bundle: .module)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: Theme.contentContentPrimary.opacity(Constants.scrimOpacity), location: 0),
                        .init(color: .clear, location: Constants.scrimEndLocation),
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            .overlay(alignment: .bottomLeading) { overlayContent }
            .clipped()
    }

    private var overlayContent: some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing24) {
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing8) {
                Text.build(theme.font.display.medium(banner.title))
                    .foregroundStyle(Theme.contentContentInvertedPrimary)
                    .multilineTextAlignment(.leading)

                Button(action: onTapCTA) {
                    Text.build(theme.font.link.medium(banner.ctaTitle, underline: true))
                        .foregroundStyle(Theme.contentContentInvertedPrimary)
                }
                .accessibilityIdentifier(AccessibilityID.cta)
            }

            if pageCount > 1 {
                HStack(spacing: Primitives.Spacing.spacing8) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        pageDot(isSelected: index == currentIndex)
                    }
                }
            }
        }
        .padding(Primitives.Spacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func pageDot(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(Theme.contentContentInvertedPrimary)
                .frame(width: Constants.activeDotSize.width, height: Constants.activeDotSize.height)
        } else {
            Circle()
                .fill(Theme.contentContentInvertedPrimary.opacity(Constants.inactiveDotOpacity))
                .frame(width: Constants.inactiveDotDiameter, height: Constants.inactiveDotDiameter)
        }
    }
}

private enum AccessibilityID {
    static let cta = "hero-cta"
}

#if DEBUG
#Preview {
    HomeHeroBannerView(banner: HomeHeroBanner.placeholders[0], pageCount: 3, currentIndex: 0)
}
#endif
