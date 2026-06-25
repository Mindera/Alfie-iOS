import SharedUI
import SwiftUI

public struct SnapCarouselDemoView: View {
    private let imageNames: [String] = (0...3).map { "CarouselImage\($0)" }
    @State private var index: Int = 0

    public var body: some View {
        VStack(spacing: Primitives.Spacing.spacing16) {
            DemoHelper.demoSectionHeader(title: "PDP Image Gallery")
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing0)
            SnapCarousel(
                itemIndex: $index
            ) {
                imageNames.map { name in
                    Image(name, bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(Sizing.radiusSoft)
                }
            }

            PaginatedControl(configuration: .init(), itemsCount: 4, selectedIndex: $index)
                .frame(maxHeight: Primitives.Spacing.spacing16)
        }
        Spacer()
    }
}
