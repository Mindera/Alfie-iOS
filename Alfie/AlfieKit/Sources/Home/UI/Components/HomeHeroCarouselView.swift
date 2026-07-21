import Model
import SharedUI
import SwiftUI

/// Full-bleed hero carousel: pages `HomeHeroBanner`s with a themed page control overlaid at the bottom.
struct HomeHeroCarouselView: View {
    private enum Constants {
        static let aspectRatio: CGFloat = 375.0 / 500.0
        static let activeDotSize = CGSize(width: 12, height: 6)
        static let inactiveDotDiameter: CGFloat = 6
        static let inactiveDotOpacity: CGFloat = 0.4
    }

    private let banners: [HomeHeroBanner]
    private let onTapCTA: (HomeHeroBanner) -> Void
    @State private var selectedIndex = 0

    init(banners: [HomeHeroBanner], onTapCTA: @escaping (HomeHeroBanner) -> Void = { _ in }) {
        self.banners = banners
        self.onTapCTA = onTapCTA
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedIndex) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    HomeHeroBannerView(banner: banner) { onTapCTA(banner) }
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .aspectRatio(Constants.aspectRatio, contentMode: .fit)

            if banners.count > 1 {
                ThemedPageControl(
                    data: banners,
                    selectedIndex: $selectedIndex,
                    configuration: .init(size: Constants.inactiveDotDiameter, spacing: Primitives.Spacing.spacing8)
                ) { _, isSelected in
                    pageDot(isSelected: isSelected)
                }
            }
        }
        .frame(maxWidth: .infinity)
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

#if DEBUG
#Preview {
    HomeHeroCarouselView(banners: HomeHeroBanner.placeholders)
}
#endif
