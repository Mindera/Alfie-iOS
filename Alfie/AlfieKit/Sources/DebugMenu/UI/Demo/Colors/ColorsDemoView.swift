import SharedUI
import SwiftUI

struct ColorsDemoView: View {
    private typealias Token = (name: String, value: Color)

    private var groups: [(title: String, tokens: [Token])] {
        [("Content", "content"), ("Surface", "surface"), ("Border", "border"), ("Link", "link"), ("Button", "button")]
            .map { title, prefix in
                (title, theme.color.allTokens.filter { $0.name.hasPrefix(prefix) })
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingMd) {
                ForEach(groups, id: \.title) { group in
                    DemoHelper.demoSectionHeader(title: group.title)
                    ForEach(group.tokens, id: \.name) { token in
                        colorRow(token)
                    }
                }
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
    }

    private func colorRow(_ token: Token) -> some View {
        HStack(spacing: theme.sizing.spacingSpacingSm) {
            RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
                .fill(token.value)
                .overlay {
                    RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
                        .stroke(theme.color.borderSoft, lineWidth: theme.sizing.borderBorderWeightDefault)
                }
                .frame(width: theme.sizing.spacingSpacing2xl, height: theme.sizing.spacingSpacing2xl)
            Text.build(theme.font.body.small("theme.color.\(token.name)"))
                .foregroundStyle(theme.color.contentContentPrimary)
        }
    }
}

#Preview {
    ColorsDemoView()
}
