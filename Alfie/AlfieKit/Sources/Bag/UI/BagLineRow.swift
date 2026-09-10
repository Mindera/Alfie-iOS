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
///
/// The two branches differ in how they read to assistive technology, and deliberately so. The
/// inert row is a container; the tappable row is a single element carrying the button trait, which
/// is what makes it one VoiceOver stop that can be activated. Either way the labels inside carry no
/// identifiers of their own: a `Button` merges its children, so a per-label identifier would be
/// unmatchable on every row a real cart holds, and one that only ever matched a slug-less row would
/// be a trap for the next test author. The count in `BagPage.lineItems` is a count of rows.
///
/// The row owns its horizontal inset rather than taking it from `BagView`. Applied from outside it
/// would wrap the `Button` instead of sitting inside its label, leaving a 16pt strip down both
/// edges of every row where a tap lands on the `List` and nothing happens.
struct BagLineRow: View {
    let line: CartLine
    let onTap: () -> Void

    var body: some View {
        if line.slug == nil {
            content
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(rowIdentifier)
        } else {
            // `.plain` so the row looks exactly as it did before it became tappable: the press
            // highlight is the whole affordance, and a tinted or bordered style would restyle every
            // label inside it.
            Button(action: onTap) {
                // The row is a `.top`-aligned `HStack` with a `Spacer`, so its drawn content leaves
                // transparent gaps — beside the total, and below the shorter text column. Without a
                // content shape those gaps are not hit-tested and "tap anywhere on the row" would be
                // false for a good part of the row's area.
                content
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(rowIdentifier)
        }
    }

    /// Both branches are the same row to a UI test, so they answer to the same identifier.
    private var rowIdentifier: String {
        AccessibilityID.Bag.lineItem(id: line.id)
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
                Text.build(theme.font.body.small(line.unitPrice.amountFormattedOrUnavailable))
                    .foregroundStyle(Theme.contentContentTerciary)
            }
            Spacer()
            Text.build(theme.font.body.medium(line.lineTotal.amountFormattedOrUnavailable))
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
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
