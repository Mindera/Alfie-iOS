import AccessibilityIdentifiers
import SharedUI
import SwiftUI

struct ScannerIntroView: View {
    let onContinue: () -> Void
    let onNotNow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingLg) {
            Text.build(theme.font.heading.small(L10n.Scanner.Intro.title))
                .foregroundStyle(theme.color.contentContentPrimary)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Text.build(theme.font.body.medium(L10n.Scanner.Intro.message))
                .foregroundStyle(theme.color.contentContentTerciary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: theme.sizing.spacingSpacingSm) {
                ThemedButton(text: L10n.Scanner.Intro.continue, isFullWidth: true, action: onContinue)
                    .accessibilityIdentifier(AccessibilityID.Scanner.introContinue)

                ThemedButton(
                    text: L10n.Scanner.Intro.notNow,
                    style: .secondary,
                    isFullWidth: true,
                    action: onNotNow
                )
                .accessibilityIdentifier(AccessibilityID.Scanner.introNotNow)
            }
        }
        .padding(theme.sizing.spacingSpacingMd)
        .padding(.top, theme.sizing.spacingSpacingMd)
        .frame(maxWidth: .infinity)
        .background(theme.color.surfaceBackgroundPrimary)
        .accessibilityIdentifier(AccessibilityID.Scanner.intro)
    }
}

#if DEBUG
#Preview {
    ScannerIntroView(onContinue: {}, onNotNow: {})
}
#endif
