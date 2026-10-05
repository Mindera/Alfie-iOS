import AccessibilityIdentifiers
import SharedUI
import SwiftUI

struct BagPurchaseSummary: View {
    let total: String

    var body: some View {
        VStack(alignment: .leading, spacing: Sizing.spacingSpacingXs) {
            HStack(alignment: .firstTextBaseline, spacing: Sizing.spacingSpacingXs) {
                Text.build(theme.font.body.mediumBold(L10n.Bag.Total.title))
                Spacer(minLength: 0)
                Text.build(theme.font.body.mediumBold(total))
            }
            .foregroundStyle(Theme.contentContentPrimary)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(AccessibilityID.Bag.grandTotal)

            Text.build(theme.font.body.small(L10n.Bag.Total.caption))
                .foregroundStyle(Theme.contentContentPrimary)

            // Checkout is not wired yet, so the button is shown and does nothing.
            ThemedButton(text: L10n.Bag.Continue.cta, isFullWidth: true) {}
                .accessibilityIdentifier(AccessibilityID.Bag.continueButton)
        }
        .padding(.vertical, Sizing.spacingSpacingXs)
        .padding(.horizontal, Sizing.spacingSpacingMd)
        .background(Theme.surfaceBackgroundPrimary)
        .overlay(alignment: .top) {
            BagDivider()
        }
    }
}
