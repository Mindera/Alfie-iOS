import AccessibilityIdentifiers
import SharedUI
import SwiftUI

struct ScannerIntroView: View {
    let onContinue: () -> Void
    let onNotNow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.space300) {
            Text.build(theme.font.heading.small(L10n.Scanner.Intro.title))
                .foregroundStyle(Theme.contentContentPrimary)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Text.build(theme.font.body.medium(L10n.Scanner.Intro.message))
                .foregroundStyle(Theme.contentContentTerciary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: theme.spacing.space150) {
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
        .padding(theme.spacing.space200)
        .padding(.top, theme.spacing.space200)
        .frame(maxWidth: .infinity)
        .background(Theme.surfaceBackgroundPrimary)
        .accessibilityIdentifier(AccessibilityID.Scanner.intro)
    }
}

#if DEBUG
#Preview {
    ScannerIntroView(onContinue: {}, onNotNow: {})
}
#endif
