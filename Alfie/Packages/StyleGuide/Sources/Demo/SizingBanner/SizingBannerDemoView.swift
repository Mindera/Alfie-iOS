import Models
import SwiftUI

struct SizingBannerDemoView: View {
    private static let selectedTitle: String = "Size:"
    private static let items: [SizingSwatch] = [
        .init(id: UUID().uuidString, name: "XS", state: .available),
        .init(id: UUID().uuidString, name: "S", state: .outOfStock),
        .init(id: UUID().uuidString, name: "M", state: .available),
        .init(id: UUID().uuidString, name: "L", state: .available),
        .init(id: UUID().uuidString, name: "XL", state: .unavailable),
        .init(id: UUID().uuidString, name: "XXL", state: .available),
        .init(id: UUID().uuidString, name: "XXXL", state: .available),
        .init(id: UUID().uuidString, name: "XXXXL", state: .available),
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
