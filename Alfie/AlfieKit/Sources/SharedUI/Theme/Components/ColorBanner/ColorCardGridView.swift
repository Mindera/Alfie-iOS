import Model
import SwiftUI

/// The design's inline colour picker: one card per colour, swatch above name, laid out in a grid.
/// `ColorSelectorComponentView` renders swatches alone, with no room for the name the card carries.
public struct ColorCardGridView: View {
    @ObservedObject private var configuration: ColorAndSizingSelectorConfiguration<ColorSwatch>
    private let columns: Int

    public init(configuration: ColorAndSizingSelectorConfiguration<ColorSwatch>, columns: Int) {
        self.configuration = configuration
        self.columns = columns
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: theme.spacing.space100), count: columns),
            spacing: theme.spacing.space100
        ) {
            ForEach(configuration.items) { item in
                card(for: item)
            }
        }
    }

    private func card(for item: ColorSwatch) -> some View {
        let isSelected = configuration.selectedItem == item
        let appearance = ColorCardAppearance.resolve(isSelected: isSelected, isDisabled: item.isDisabled)

        return VStack(spacing: theme.spacing.space100) {
            ColorSwatchView(item: item, swatchSize: .small, isSelected: false)

            Text.build(theme.font.body.medium(item.name.capitalized))
                // The token's line height, which `Text` does not apply on its own.
                .frame(minHeight: theme.font.body.medium.style.lineHeight)
                .lineLimit(1)
                .foregroundStyle(appearance.textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.space100)
        .background(
            // The design draws the card square, so no corner radius token applies.
            Rectangle()
                .inset(by: appearance.borderWidth / 2)
                .stroke(appearance.borderColor, lineWidth: appearance.borderWidth)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.selectedItem = item
        }
        .disabled(item.isDisabled)
        .accessibilityElement(children: .combine)
        // Selection is drawn as a border, which assistive technology cannot see.
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    ColorCardGridView(
        configuration: .init(
            items: [
                .init(id: "1", name: "White", type: .color(.white)),
                .init(id: "2", name: "Black", type: .color(.black)),
                .init(id: "3", name: "Terracotta", type: .color(.orange)),
            ],
            selectedItem: .init(id: "2", name: "Black", type: .color(.black))
        ),
        columns: 3
    )
}
