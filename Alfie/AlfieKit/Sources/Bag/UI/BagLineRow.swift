import AccessibilityIdentifiers
import Core
import Model
import SharedUI
import SwiftUI

/// One Line of the Cart. `HorizontalProductCard` takes a `Product` and has no slot for a quantity
/// or a line total, so the bag brings its own row.
///
/// The whole row opens the line's product. A line the BFF sent without a slug has no handle to
/// fetch a product page by, so it stays inert rather than offering a press it could not honour —
/// which is also what keeps VoiceOver from announcing it as a button.
///
/// The inert row is a container; the tappable row is a single element carrying the button trait.
/// The labels inside carry no identifiers of their own: a `Button` merges its children, so a
/// per-label identifier would be unmatchable on every row a real cart holds.
///
/// The row owns its horizontal inset. Applied from `BagView` it would wrap the `Button` instead of
/// sitting inside its label, leaving a strip down both edges where a tap does nothing.
struct BagLineRow: View {
    let line: CartLine
    let onTap: () -> Void

    var body: some View {
        if line.slug == nil {
            content
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(rowIdentifier)
        } else {
            Button(action: onTap) {
                // Without a content shape the transparent gaps in the text column are not hit-tested.
                content
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(rowIdentifier)
        }
    }

    private var rowIdentifier: String {
        AccessibilityID.Bag.lineItem(id: line.id)
    }

    private var content: some View {
        HStack(alignment: .top, spacing: Primitives.Spacing.spacing8) {
            BagLineImage(url: line.imageURL, altText: line.imageAltText)
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing8) {
                // A line with no name is still a line the shopper is being charged for.
                if let name = line.name {
                    Text.build(theme.font.body.medium(name))
                        .lineLimit(Constants.nameLineLimit)
                }
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: Primitives.Spacing.spacing8) {
                    Text.build(theme.font.body.medium(L10n.Bag.Quantity.label(line.quantity)))
                    Spacer(minLength: 0)
                    Text.build(theme.font.body.mediumBold(line.lineTotal.amountFormattedOrUnavailable))
                }
            }
            .foregroundStyle(Theme.contentContentPrimary)
            .frame(minHeight: Constants.imageSize.height)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }
}

private struct BagLineImage: View {
    let url: URL?
    let altText: String?

    var body: some View {
        Theme.surfaceForegroundPrimary
            .frame(width: Constants.imageSize.width, height: Constants.imageSize.height)
            .overlay {
                if let url {
                    RemoteImage(
                        url: url,
                        success: { image in
                            image
                                .resizable()
                                .scaledToFill()
                        },
                        placeholder: { Theme.surfaceForegroundPrimary },
                        failure: { _ in Theme.surfaceForegroundPrimary }
                    )
                    .accessibilityLabel(altText ?? "")
                }
            }
            .clipped()
    }
}

private enum Constants {
    static let imageSize = CGSize(width: 114, height: 152)
    static let nameLineLimit: Int = 2
}
