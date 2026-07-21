import Model
import SharedUI
import SwiftUI

/// Full-bleed hero carousel: pages `HomeHeroBanner`s; each page renders its own overlay + page dots.
struct HomeHeroCarouselView: View {
    private enum Constants {
        static let aspectRatio: CGFloat = 375.0 / 500.0
    }

    private let banners: [HomeHeroBanner]
    private let onTapCTA: (HomeHeroBanner) -> Void
    @State private var selectedIndex = 0

    init(banners: [HomeHeroBanner], onTapCTA: @escaping (HomeHeroBanner) -> Void = { _ in }) {
        self.banners = banners
        self.onTapCTA = onTapCTA
    }

    var body: some View {
        // Bound the paged TabView to an explicit height so each page's bottom overlay isn't clipped.
        GeometryReader { proxy in
            TabView(selection: $selectedIndex) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    HomeHeroBannerView(
                        banner: banner,
                        pageCount: banners.count,
                        currentIndex: selectedIndex,
                        size: proxy.size
                    ) {
                        onTapCTA(banner)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(Constants.aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview {
    HomeHeroCarouselView(banners: HomeHeroBanner.placeholders)
}
#endif
