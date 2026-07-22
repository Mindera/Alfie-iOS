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
    @State private var selectedID: String

    init(banners: [HomeHeroBanner], onTapCTA: @escaping (HomeHeroBanner) -> Void = { _ in }) {
        self.banners = banners
        self.onTapCTA = onTapCTA
        _selectedID = State(initialValue: banners.first?.id ?? "")
    }

    private var currentIndex: Int {
        banners.firstIndex { $0.id == selectedID } ?? 0
    }

    var body: some View {
        // Bound the paged TabView to an explicit height so each page's bottom overlay isn't clipped.
        GeometryReader { proxy in
            TabView(selection: $selectedID) {
                ForEach(banners) { banner in
                    HomeHeroBannerView(
                        banner: banner,
                        pageCount: banners.count,
                        currentIndex: currentIndex,
                        size: proxy.size
                    ) {
                        onTapCTA(banner)
                    }
                    .tag(banner.id)
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
