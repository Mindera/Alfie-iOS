import Model
import SwiftUI

/// Collapsed colour representation for the product info block: the selected swatch plus a count of
/// the remaining colours. Nothing in SharedUI covers this shape, hence a dedicated small component.
public struct ColorSummaryView: View {
    private let selectedItem: ColorSwatch
    private let remainingCount: Int

    public init(selectedItem: ColorSwatch, remainingCount: Int) {
        self.selectedItem = selectedItem
        self.remainingCount = remainingCount
    }

    public var body: some View {
        HStack(spacing: theme.spacing.space100) {
            ColorSwatchView(item: selectedItem, swatchSize: .small, isSelected: false)
            Text.build(theme.font.body.medium(L10n.Pdp.ColourSummary.count(remainingCount)))
                .foregroundStyle(Theme.contentContentPrimary)
        }
        // The swatch and count read as one thing; without this the count reads alone as "+1".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.Pdp.ColourSummary.accessibilityLabel(selectedItem.name, remainingCount))
        .frame(minHeight: Constants.minRowHeight)
    }
}

private enum Constants {
    static let minRowHeight: CGFloat = 44
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    ColorSummaryView(
        selectedItem: .init(id: "1", name: "Black", type: .color(.black)),
        remainingCount: 3
    )
}
