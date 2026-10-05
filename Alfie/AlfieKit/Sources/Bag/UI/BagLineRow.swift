import AccessibilityIdentifiers
import Core
import Model
import SharedUI
import SwiftUI

/// `HorizontalProductCard` takes a `Product` and has no slot for a quantity or a line total, so
/// the bag brings its own row.
///
/// The labels inside carry no identifiers of their own: a `Button` merges its children, so a
/// per-label identifier would be unmatchable on every row a real cart holds.
///
/// The row owns its horizontal inset. Applied from `BagView` it would wrap the `Button` instead of
/// sitting inside its label, leaving a strip down both edges where a tap does nothing.
struct BagLineRow: View {
    let line: CartLine
    let onTap: () -> Void

    var body: some View {
        // A single root keeps the row's structure constant, so `List` can template row identity.
        VStack(spacing: 0) {
            if line.slug == nil {
                BagLineContent(line: line)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(rowIdentifier)
            } else {
                Button(action: onTap) {
                    // Without a content shape the transparent gaps in the text column are not hit-tested.
                    BagLineContent(line: line)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(rowIdentifier)
            }
        }
    }

    private var rowIdentifier: String {
        AccessibilityID.Bag.lineItem(id: line.id)
    }
}

extension BagLineRow {
    static let imageSize = CGSize(width: 114, height: 152)
}

private struct BagLineContent: View {
    let line: CartLine

    var body: some View {
        HStack(alignment: .top, spacing: Sizing.spacingSpacingXs) {
            BagLineImage(url: line.imageURL, altText: line.imageAltText)
            VStack(alignment: .leading, spacing: Sizing.spacingSpacingXs) {
                if let name = line.name {
                    Text.build(theme.font.body.medium(name))
                        .lineLimit(Constants.nameLineLimit)
                }
                Spacer(minLength: 0)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: Sizing.spacingSpacingXs) {
                        quantity
                        Spacer(minLength: 0)
                        lineTotal
                    }
                    VStack(alignment: .leading, spacing: Sizing.spacingSpacingXs) {
                        quantity
                        lineTotal
                    }
                }
            }
            .foregroundStyle(Theme.contentContentPrimary)
            .frame(minHeight: BagLineRow.imageSize.height)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, Sizing.spacingSpacingMd)
    }

    private var quantity: some View {
        Text.build(theme.font.body.medium(L10n.Bag.Quantity.label(line.quantity)))
    }

    private var lineTotal: some View {
        Text.build(theme.font.body.mediumBold(line.lineTotal.amountFormattedOrUnavailable))
    }
}

private struct BagLineImage: View {
    let url: URL?
    let altText: String?

    var body: some View {
        Theme.surfaceForegroundPrimary
            .frame(width: BagLineRow.imageSize.width, height: BagLineRow.imageSize.height)
            .overlay {
                if let url {
                    RemoteImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    }
                    .accessibilityLabel(altText ?? "")
                    .accessibilityHidden(altText?.isEmpty ?? true)
                }
            }
            .clipped()
            .contentShape(Rectangle())
    }
}

private enum Constants {
    static let nameLineLimit: Int = 2
}
