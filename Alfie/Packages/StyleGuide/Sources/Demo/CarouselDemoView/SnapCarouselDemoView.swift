import SwiftUI

public struct SnapCarouselDemoView: View {
    private let imageNames: [String] = (0...3).map { "CarouselImage\($0)" }
    @State private var index: Int = 0

    public var body: some View {
        VStack(spacing: Spacing.space200) {
            DemoHelper.demoSectionHeader(title: "PDP Image Gallery")
                .padding(.horizontal, Spacing.space200)
                .padding(.bottom, Spacing.space0)
            SnapCarousel(itemIndex: $index,
                         items: {
                imageNames.map { name in
                    Image(name, bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(CornerRadius.s)
                }
            })
            PaginatedControl(configuration: .init(),
                             itemsCount: 4,
                             selectedIndex: $index)
            .frame(maxHeight: Spacing.space200)
        }
        Spacer()
    }
}
