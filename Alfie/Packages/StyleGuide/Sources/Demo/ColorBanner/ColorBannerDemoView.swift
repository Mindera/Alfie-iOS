import Models
import SwiftUI

struct ColorBannerDemoView: View {
    private static let selectedTitle: String = "Color:"
    private static let selectedImageTitle: String = "Pattern:"
    private static let items: [ColorSwatch] = [
        .init(name: "Black", type: .color(.black)),
        .init(name: "Gray", type: .color(.gray)),
        .init(name: "Red", type: .color(.red), isDisabled: true),
        .init(name: "Green", type: .color(.green)),
        .init(name: "Blue", type: .color(.blue)),
        .init(name: "Yellow", type: .color(.yellow), isDisabled: true),
        .init(name: "Brown", type: .color(.brown), isDisabled: true),
        .init(name: "Orange", type: .color(.orange)),
        .init(name: "Pink", type: .color(.pink)),
    ]

    private static let itemsSmall: [ColorSwatch] = [
        .init(name: "Black", type: .color(.black)),
        .init(name: "Gray", type: .color(.gray)),
        .init(name: "Red", type: .color(.red), isDisabled: true),
        .init(name: "Green", type: .color(.green)),
        .init(name: "Blue", type: .color(.blue)),
        .init(name: "Yellow", type: .color(.yellow), isDisabled: true),
        .init(name: "Brown", type: .color(.brown), isDisabled: true),
        .init(name: "Orange", type: .color(.orange)),
        .init(name: "Pink", type: .color(.pink)),
    ]

    private static let itemsImage: [ColorSwatch] = [
        .init(name: "Pattern 1", type: .image(Image("pattern1", bundle: .module))),
        .init(name: "Pattern 2", type: .image(Image("pattern2", bundle: .module))),
        .init(name: "Pattern 3", type: .image(Image("pattern3", bundle: .module)), isDisabled: true),
        .init(name: "Pattern 4", type: .image(Image("pattern4", bundle: .module))),
        .init(name: "Pattern 5", type: .image(Image("pattern5", bundle: .module))),
        .init(name: "Pattern 6", type: .image(Image("pattern6", bundle: .module)), isDisabled: true),
        .init(name: "Pattern 1", type: .image(Image("pattern1", bundle: .module)), isDisabled: true),
        .init(name: "Pattern 2", type: .image(Image("pattern2", bundle: .module))),
        .init(name: "Pattern 3", type: .image(Image("pattern3", bundle: .module))),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                Spacer()
                section(title: "Color Swatches - Scrollable") {
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.items),
                        layoutConfiguration: .init(arrangement: .horizontal(itemSpacing: Spacing.space100))
                    )
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.itemsSmall),
                        layoutConfiguration: .init(arrangement: .horizontal(itemSpacing: Spacing.space100))
                    )
                }

                Spacer()

                section(title: "Color Swatches - Chips") {
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.items),
                        layoutConfiguration: .init(
                            arrangement: .chips(
                                itemHorizontalSpacing: Spacing.space100, itemVerticalSpacing: Spacing.space100
                            )
                        )
                    )
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.itemsSmall),
                        layoutConfiguration: .init(
                            arrangement: .chips(
                                itemHorizontalSpacing: Spacing.space100, itemVerticalSpacing: Spacing.space100
                            )
                        )
                    )
                }

                Spacer()

                section(title: "Color Swatches - Grid") {
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.items),
                        layoutConfiguration: .init(arrangement: .grid(columns: 5, columnWidth: 50))
                    )
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedTitle, items: Self.itemsSmall),
                        layoutConfiguration: .init(arrangement: .grid(columns: 5, columnWidth: 50))
                    )
                }

                Spacer()

                section(title: "Image Swatches - Grid") {
                    ColorSelectorComponentView(
                        configuration: .init(selectedTitle: Self.selectedImageTitle, items: Self.itemsImage),
                        layoutConfiguration: .init(arrangement: .grid(columns: 5, columnWidth: 50))
                    )
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
        }
    }

    private func section(title: String, @ViewBuilder content: () -> any View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space400) {
            DemoHelper.demoSectionHeader(title: title)
            AnyView(content())
        }
    }
}

#Preview {
    ColorBannerDemoView()
}
