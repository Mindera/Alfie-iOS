import SharedUI
import SwiftUI

struct SpacingDemoView: View {
    private var tokens: [(name: String, value: CGFloat)] {
        theme.sizing.allTokens
            .filter { $0.name.hasPrefix("spacingSpacing") }
            .sorted { $0.value < $1.value }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingMd) {
                DemoHelper.demoSectionHeader(title: "Spacing")
                ForEach(tokens, id: \.name) { token in
                    spacingView(token: token.name, token.value)
                }
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
    }

    private func spacingView(token: String, _ spacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingNone) {
            HStack {
                Text.build(theme.font.body.medium("theme.sizing.\(token)"))
                Text.build(theme.font.body.small("\(Int(spacing))pt"))
                Spacer()
            }
            ThemedDivider.horizontalThick
                .padding(.top, theme.sizing.spacingSpacing3xs)

            Image(systemName: "arrow.down.to.line")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: theme.sizing.spacingSpacingMd)
                .background(theme.color.surfaceBackgroundInvertedPrimary)
                .foregroundStyle(theme.color.contentContentInvertedPrimary)
                .padding(.top, theme.sizing.spacingSpacingMd)

            Spacer(minLength: spacing)

            Image(systemName: "arrow.up.to.line")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: theme.sizing.spacingSpacingMd)
                .background(theme.color.surfaceBackgroundInvertedPrimary)
                .foregroundStyle(theme.color.contentContentInvertedPrimary)
                .padding(.bottom, theme.sizing.spacingSpacingMd)
        }
    }
}

#Preview {
    SpacingDemoView()
}
