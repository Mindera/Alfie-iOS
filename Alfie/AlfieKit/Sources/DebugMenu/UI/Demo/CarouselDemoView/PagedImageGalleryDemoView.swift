import SharedUI
import SwiftUI

public struct PagedImageGalleryDemoView: View {
    private enum Constants {
        static let itemAspectRatio: CGFloat = 0.77
    }

    private let imageNames: [String] = (0...3).map { "CarouselImage\($0)" }
    @State private var index: Int = 0

    public var body: some View {
        VStack(spacing: Primitives.Spacing.spacing16) {
            DemoHelper.demoSectionHeader(title: "PDP Image Gallery")
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing0)
            // A paged TabView does not take its height from its pages, so the ratio is imposed here.
            GeometryReader { proxy in
                TabView(selection: $index) {
                    ForEach(Array(imageNames.enumerated()), id: \.offset) { offset, name in
                        Image(name, bundle: .module)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(Sizing.radiusSoft)
                            .tag(offset)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .aspectRatio(Constants.itemAspectRatio, contentMode: .fit)

            PaginatedControl(configuration: .init(), itemsCount: 4, selectedIndex: $index)
                .frame(maxHeight: Primitives.Spacing.spacing16)
        }
        Spacer()
    }
}
