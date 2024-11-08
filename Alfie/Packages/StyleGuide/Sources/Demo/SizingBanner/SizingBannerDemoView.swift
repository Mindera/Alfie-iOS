import Models
import SwiftUI

struct SizingBannerDemoView: View {
    private static let selectedTitle: String = "Size:"
    private static let items: [SizingSwatch] = [
        .init(name: "XS", state: .available),
        .init(name: "S", state: .outOfStock),
        .init(name: "M", state: .available),
        .init(name: "L", state: .available),
        .init(name: "XL", state: .unavailable),
        .init(name: "XXL", state: .available),
        .init(name: "XXXL", state: .available),
        .init(name: "XXXXL", state: .available),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                section(title: "Sizing Swatches - Scrollable") {
                    SizingSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.items),
                        layoutConfiguration: .init(arrangement: .horizontal(itemSpacing: Spacing.space100))
                    )
                }

                Spacer()

                section(title: "Sizing Swatches - Chips") {
                    SizingSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.items),
                        layoutConfiguration: .init(
                            arrangement: .chips(
                                itemHorizontalSpacing: Spacing.space100,
                                itemVerticalSpacing: Spacing.space100
                            )
                        )
                    )
                }

                Spacer()

                section(title: "Sizing Swatches - Grid") {
                    SizingSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.items),
                        layoutConfiguration: .init(arrangement: .grid(columns: 4, columnWidth: 50))
                    )
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
        }
    }

    private func section(title: String, @ViewBuilder content: () -> any View) -> some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: title)
                .padding(.bottom, Spacing.space400)

            AnyView(content())
        }
    }
}

#Preview {
    SizingBannerDemoView()
}
