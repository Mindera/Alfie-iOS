import AccessibilityIdentifiers
import SharedUI
import SwiftUI

/// Explains why the camera is needed before iOS asks for it, so the one-time system prompt is
/// answered knowingly.
public struct ScannerIntroView: View {
    private let onContinue: () -> Void
    private let onNotNow: () -> Void

    public init(onContinue: @escaping () -> Void, onNotNow: @escaping () -> Void) {
        self.onContinue = onContinue
        self.onNotNow = onNotNow
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Theme.surfaceBackgroundInvertedPrimary
                .opacity(Constants.dimmingOpacity)
                .ignoresSafeArea()
                .onTapGesture(perform: onNotNow)
                .accessibilityHidden(true)

            sheet
                .transition(.move(edge: .bottom))
        }
        .accessibilityIdentifier(AccessibilityID.Scanner.intro)
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: theme.spacing.space300) {
            header

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
        .padding(.bottom, theme.spacing.space200)
        .frame(maxWidth: .infinity)
        .background(Theme.surfaceBackgroundPrimary.ignoresSafeArea(edges: .bottom))
    }

    private var header: some View {
        ZStack {
            Text.build(theme.font.body.medium(L10n.Scanner.Intro.title))
                .foregroundStyle(Theme.contentContentPrimary)
                .accessibilityAddTraits(.isHeader)

            Button(action: onNotNow) {
                ThemedIcon(.close, size: .medium, tint: Theme.contentContentPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(Text(L10n.Accessibility.close))
        }
    }
}

private enum Constants {
    static let dimmingOpacity: Double = 0.4
}

#if DEBUG
#Preview {
    ScannerIntroView(onContinue: {}, onNotNow: {})
}
#endif
