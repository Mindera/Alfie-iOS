import SharedUI
import SwiftUI

struct CarouselDemoView: View {
    enum Constants {
        static let imageCount = 4
    }

    @State private var currentIndex = 0
    @State private var isFullScreen = false

    var body: some View {
        VStack(spacing: 0) {
            DemoHelper.demoSectionHeader(title: "PDP Image Gallery")
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing0)

            Carousel(currentIndex: $currentIndex, aspectRatio: 487 / 634) {
                (0...Constants.imageCount - 1).map {
                    Image("CarouselImage\($0)", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            isFullScreen = true
                        }
                }
            }
            .disabled(isFullScreen)
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing8) {
                Text.build(theme.font.heading.medium("BOSS"))
                Text.build(theme.font.body.medium("RAY COMPUTER BAG"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Primitives.Spacing.spacing16)

            Spacer()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            ZoomableCarousel(currentIndex: $currentIndex, configuration: .init(isPresented: $isFullScreen)) {
                (0...Constants.imageCount - 1).map {
                    Image("CarouselImage\($0)", bundle: .module)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}

#Preview {
    CarouselDemoView()
}
