import Model
import SwiftUI

public struct SizingSwatchView: View {
    private let item: SizingSwatch
    private let isSelected: Bool

    private var appearance: SizingSwatchAppearance {
        .resolve(for: item.state, isSelected: isSelected)
    }

    public init(item: SizingSwatch, isSelected: Bool) {
        self.item = item
        self.isSelected = isSelected
    }

    public var body: some View {
        Text.build(theme.font.body.medium(item.name))
            // The token's line height, which `Text` does not apply on its own — without it the chip
            // renders 6pt shorter than the design and the bell reads oversized against it.
            .frame(maxWidth: .infinity, minHeight: theme.font.body.medium.style.lineHeight)
            .lineLimit(1)
            .padding(theme.spacing.space100)
            .foregroundStyle(appearance.textColor)
            .background(
                ZStack {
                    // The design draws the chip square, so no corner radius token applies.
                    Rectangle()
                        .fill(appearance.backgroundColor)

                    Rectangle()
                        .inset(by: appearance.borderWidth / 2)
                        .stroke(appearance.borderColor, lineWidth: appearance.borderWidth)

                    outOfStockSlashView
                }
            )
            .overlay(alignment: .topTrailing) {
                outOfStockBellView
            }
            .accessibilityElement(children: .combine)
            // Selection is drawn as a border, which assistive technology cannot see.
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityValue(appearance.isCrossedOut ? L10n.Product.Size.OutOfStock.accessibilityValue : "")
    }

    @ViewBuilder private var outOfStockSlashView: some View {
        if appearance.isCrossedOut {
            UnavailableCrossedOutShape(direction: .topLeadingToBottomTrailing)
                .stroke(appearance.borderColor, style: StrokeStyle(lineWidth: appearance.borderWidth))
                .padding(appearance.borderWidth)
        }
    }

    /// Decoration only: notify-me has no service behind it yet, so the bell carries no tap target
    /// and no accessibility label. The design insets it from the corner rather than centring it.
    @ViewBuilder private var outOfStockBellView: some View {
        if appearance.isCrossedOut {
            ThemedIcon(.bell, tint: Theme.contentContentTerciary)
                .padding(.top, theme.spacing.space050)
                .padding(.trailing, theme.spacing.space025)
        }
    }
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        SizingSwatchView(item: .init(id: "1", name: "Default", state: .available), isSelected: false)

        SizingSwatchView(item: .init(id: "2", name: "Selected", state: .available), isSelected: true)

        SizingSwatchView(item: .init(id: "3", name: "Unavailable", state: .unavailable), isSelected: false)

        SizingSwatchView(item: .init(id: "4", name: "Out of Stock", state: .outOfStock), isSelected: false)
    }
}
