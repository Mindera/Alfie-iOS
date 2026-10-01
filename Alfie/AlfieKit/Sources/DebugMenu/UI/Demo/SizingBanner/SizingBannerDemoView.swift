import Model
import SharedUI
import SwiftUI

struct SizingBannerDemoView: View {
    @State private var selectedItem: SizingSwatch?

    private static let items: [SizingSwatch] = [
        .init(id: "1", name: "XS", state: .available),
        .init(id: "2", name: "S", state: .outOfStock),
        .init(id: "3", name: "M", state: .available),
        .init(id: "4", name: "L", state: .available),
        .init(id: "5", name: "XL", state: .outOfStock),
        .init(id: "6", name: "XXL", state: .available),
        .init(id: "7", name: "XXXL", state: .available),
        .init(id: "8", name: "XXXXL", state: .available),
    ]

    private var configuration: SwatchSelectorConfiguration<SizingSwatch> {
        .init(items: Self.items, selectedItem: selectedItem, onSelect: { selectedItem = $0 })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Primitives.Spacing.spacing20) {
                section(title: "Sizing Swatches - Scrollable") {
                    SizingSelectorComponentView(
                        configuration: configuration,
                        arrangement: .horizontal(itemSpacing: Primitives.Spacing.spacing8)
                    )
                }

                Spacer()

                section(title: "Sizing Swatches - Chips") {
                    SizingSelectorComponentView(
                        configuration: configuration,
                        arrangement: .chips(
                            itemHorizontalSpacing: Primitives.Spacing.spacing8,
                            itemVerticalSpacing: Primitives.Spacing.spacing8
                        )
                    )
                }

                Spacer()

                section(title: "Sizing Swatches - Grid") {
                    SizingSelectorComponentView(
                        configuration: configuration,
                        arrangement: .grid(columns: 4)
                    )
                }

                Spacer()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }

    private func section(title: String, @ViewBuilder content: () -> any View) -> some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: title)
                .padding(.bottom, Primitives.Spacing.spacing32)

            AnyView(content())
        }
    }
}

#Preview {
    SizingBannerDemoView()
}
