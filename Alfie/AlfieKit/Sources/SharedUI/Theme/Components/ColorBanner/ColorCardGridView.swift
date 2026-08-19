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
                ColorCardView(item: item, isSelected: configuration.selectedItem == item) {
                    configuration.selectedItem = item
                }
            }
        }
    }
}

// MARK: - ColorCardView

/// A struct rather than a builder func on the grid, so each card is a view SwiftUI can identify and
/// lay out on its own rather than a fragment of the grid's body.
private struct ColorCardView: View {
    let item: ColorSwatch
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let appearance = ColorCardAppearance.resolve(isSelected: isSelected, isDisabled: item.isDisabled)

        // A `Button`, not a tap gesture: the card is a control, so it belongs in the Buttons rotor,
        // and only a control announces "dimmed" when an out-of-stock colour disables it.
        return Button(action: onTap) {
            VStack(spacing: theme.spacing.space100) {
                ColorSwatchView(item: item, swatchSize: .normal, isSelected: false)

                // The design bolds the selected colour's name, so selection survives even where the
                // border cannot show it — an out-of-stock colour draws no selected border.
                Text.build(
                    appearance.isSelected
                        ? theme.font.body.mediumBold(item.name.capitalized)
                        : theme.font.body.medium(item.name.capitalized)
                )
                    // The token's line height, which `Text` does not apply on its own. Real colour
                    // names ("Midnight Navy") do not fit a third of the width on one line, so the
                    // label wraps — capped at two lines, past which a card would tower over its row.
                    .frame(minHeight: theme.font.body.medium.style.lineHeight)
                    .lineLimit(Constants.nameLineLimit)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(appearance.textColor)
            }
            // Cards in one row share that row's height; `LazyVGrid` sizes each row on its own, so
            // rows can still differ.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(theme.spacing.space100)
            .background(
                // The design draws the card square, so no corner radius token applies.
                Rectangle()
                    .inset(by: appearance.borderWidth / 2)
                    .stroke(appearance.borderColor, lineWidth: appearance.borderWidth)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(item.isDisabled)
        // Selection is drawn as a border, which assistive technology cannot see. Taken from the
        // appearance, so an out-of-stock card that draws no border does not announce one either.
        .accessibilityAddTraits(appearance.isSelected ? .isSelected : [])
        // "Dimmed" alone does not say why; the size chip announces the same reason.
        .accessibilityValueOrNone(item.isDisabled ? L10n.Pdp.Colour.OutOfStock.accessibilityValue : nil)
    }
}

private enum Constants {
    static let nameLineLimit = 2
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    ColorCardGridView(
        configuration: .init(
            items: [
                .init(id: "1", name: "White", type: .color(.white)),
                .init(id: "2", name: "Black", type: .color(.black)),
                .init(id: "3", name: "Terracotta", type: .color(.orange)),
                .init(id: "4", name: "Midnight Navy", type: .color(.blue)),
                .init(id: "5", name: "Sand", type: .color(.brown), isDisabled: true),
            ],
            selectedItem: .init(id: "2", name: "Black", type: .color(.black))
        ),
        columns: 3
    )
}
