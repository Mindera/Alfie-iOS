import AccessibilityIdentifiers
import Core
import Model
import SharedUI
import SwiftUI

/// One line of the server cart. `HorizontalProductCard` was the obvious candidate, but it has no
/// slot for a quantity or a line total and carries colour and size a `CartItem` does not know
/// (Q13/T6), so the bag brings its own row.
///
/// Not tappable: bag → PDP navigation was dropped by team decision (T6).
struct BagLineRow: View {
    let line: CartLine

    var body: some View {
        HStack(alignment: .top, spacing: Primitives.Spacing.spacing16) {
            imageView
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing8) {
                // A line with no name is still a line the shopper is being charged for, so the row
                // renders without it rather than being dropped.
                if let name = line.name {
                    Text.build(theme.font.body.small(name))
                        .lineLimit(Constants.nameLineLimit)
                }
                Text.build(theme.font.body.small(L10n.Bag.Quantity.label(line.quantity)))
                    .foregroundStyle(Primitives.Colours.neutrals500)
                    .accessibilityIdentifier(AccessibilityID.Bag.lineItemQuantity(id: line.id))
                Text.build(theme.font.body.small(line.unitPrice.amountFormatted))
                    .foregroundStyle(Primitives.Colours.neutrals500)
            }
            Spacer()
            Text.build(theme.font.body.medium(lineTotalText))
                .accessibilityIdentifier(AccessibilityID.Bag.lineItemTotal(id: line.id))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.Bag.lineItem(id: line.id))
    }

    /// An em dash where the server sent a total that cannot be rendered. Printing the £0.00 that
    /// the money conversion's zero fallback would give reads as "this item is free" (Q36).
    private var lineTotalText: String {
        line.lineTotal?.amountFormatted ?? Constants.unknownTotal
    }

    @ViewBuilder private var imageView: some View {
        VStack {
            RemoteImage(
                url: line.imageURL,
                success: { image in
                    image
                        .resizable()
                        .scaledToFit()
                },
                placeholder: { Primitives.Colours.neutrals100 },
                failure: { _ in Primitives.Colours.neutrals100 }
            )
        }
        .frame(width: Constants.imageWidth, height: Constants.imageHeight)
        .accessibilityLabel(line.imageAltText ?? "")
    }
}

private enum Constants {
    static let imageWidth: CGFloat = 75
    static let imageRatio: CGFloat = 100 / 75
    static var imageHeight: CGFloat { imageWidth * imageRatio }
    static let nameLineLimit: Int = 2
    static let unknownTotal = "—"
}
