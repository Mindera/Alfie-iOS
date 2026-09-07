import AccessibilityIdentifiers
import Core
import Model
import SharedUI
import SwiftUI

/// One line of the server cart. `HorizontalProductCard` was the obvious candidate, but it has no
/// slot for a quantity or a line total and carries colour and size a `CartItem` does not know
/// (Q13/T6), so the bag brings its own row.
///
/// The whole row opens the line's product. A line the BFF sent without a slug has no handle to
/// fetch a product page by, so it stays the plain row it has always been rather than offering a
/// press it could not honour — which is also what keeps VoiceOver from announcing it as a button.
struct BagLineRow: View {
    let line: CartLine
    let onTap: () -> Void

    var body: some View {
        if line.slug == nil {
            content
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(AccessibilityID.Bag.lineItem(id: line.id))
        } else {
            // `.plain` so the row looks exactly as it did before it became tappable: the press
            // highlight is the whole affordance, and a tinted or bordered style would restyle every
            // label inside it.
            Button(action: onTap) {
                content
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.Bag.lineItem(id: line.id))
        }
    }

    /// The row as drawn, identical either way — only what wraps it changes.
    private var content: some View {
        HStack(alignment: .top, spacing: Primitives.Spacing.spacing16) {
            // A line with no image renders without one, rather than reserving an empty grey slot.
            // `RemoteImage`'s placeholder is for a URL that is still loading, not for a line that
            // never had a URL to load.
            if line.imageURL != nil {
                imageView
            }
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing8) {
                // A line with no name is still a line the shopper is being charged for, so the row
                // renders without it rather than being dropped.
                if let name = line.name {
                    Text.build(theme.font.body.small(name))
                        .lineLimit(Constants.nameLineLimit)
                }
                Text.build(theme.font.body.small(L10n.Bag.Quantity.label(line.quantity)))
                    .foregroundStyle(Theme.contentContentTerciary)
                    .accessibilityIdentifier(AccessibilityID.Bag.lineItemQuantity(id: line.id))
                Text.build(theme.font.body.small(line.unitPrice.amountFormattedOrUnavailable))
                    .foregroundStyle(Theme.contentContentTerciary)
            }
            Spacer()
            Text.build(theme.font.body.medium(line.lineTotal.amountFormattedOrUnavailable))
                .accessibilityIdentifier(AccessibilityID.Bag.lineItemTotal(id: line.id))
        }
    }

    private var imageView: some View {
        RemoteImage(
            url: line.imageURL,
            success: { image in
                image
                    .resizable()
                    .scaledToFit()
            },
            placeholder: { Theme.surfaceForegroundPrimary },
            failure: { _ in Theme.surfaceForegroundPrimary }
        )
        .frame(width: Constants.imageWidth, height: Constants.imageHeight)
        .accessibilityLabel(line.imageAltText ?? "")
    }
}

private enum Constants {
    static let imageWidth: CGFloat = 75
    static let imageRatio: CGFloat = 100 / 75
    static var imageHeight: CGFloat { imageWidth * imageRatio }
    static let nameLineLimit: Int = 2
}
