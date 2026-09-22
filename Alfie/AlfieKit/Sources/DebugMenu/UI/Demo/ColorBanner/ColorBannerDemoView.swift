import Model
import SharedUI
import SwiftUI

struct ColorBannerDemoView: View {
    @State private var selectedItem: ColorSwatch?
    @State private var selectedImageItem: ColorSwatch?

    private static let items: [ColorSwatch] = [
        .init(id: "1", name: "Black", type: .color(.black)),
        .init(id: "2", name: "Gray", type: .color(.gray)),
        .init(id: "3", name: "Red", type: .color(.red), isDisabled: true),
        .init(id: "4", name: "Green", type: .color(.green)),
        .init(id: "5", name: "Midnight Navy", type: .color(.blue)),
        .init(id: "6", name: "Yellow", type: .color(.yellow), isDisabled: true),
    ]

    private static let itemsImage: [ColorSwatch] = [
        .init(id: "1", name: "Pattern 1", type: .image(Image("pattern1", bundle: .module))),
        .init(id: "2", name: "Pattern 2", type: .image(Image("pattern2", bundle: .module))),
        .init(id: "3", name: "Pattern 3", type: .image(Image("pattern3", bundle: .module)), isDisabled: true),
        .init(id: "4", name: "Pattern 4", type: .image(Image("pattern4", bundle: .module))),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Primitives.Spacing.spacing20) {
                Spacer()

                section(title: "Colour Cards - 3 columns") {
                    ColorCardGridView(
                        configuration: .init(
                            items: Self.items,
                            selectedItem: selectedItem,
                            onSelect: { selectedItem = $0 }
                        ),
                        columns: 3
                    )
                }

                Spacer()

                section(title: "Colour Cards - 2 columns") {
                    ColorCardGridView(
                        configuration: .init(
                            items: Self.items,
                            selectedItem: selectedItem,
                            onSelect: { selectedItem = $0 }
                        ),
                        columns: 2
                    )
                }

                Spacer()

                section(title: "Image Swatches") {
                    ColorCardGridView(
                        configuration: .init(
                            items: Self.itemsImage,
                            selectedItem: selectedImageItem,
                            onSelect: { selectedImageItem = $0 }
                        ),
                        columns: 3
                    )
                }

                Spacer()

                section(title: "Colour Summary") {
                    ColorSummaryView(selectedItem: Self.items[0], remainingCount: Self.items.count - 1)
                }

                Spacer()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }

    private func section(title: String, @ViewBuilder content: () -> any View) -> some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing32) {
            DemoHelper.demoSectionHeader(title: title)
            AnyView(content())
        }
    }
}

#Preview {
    ColorBannerDemoView()
}
