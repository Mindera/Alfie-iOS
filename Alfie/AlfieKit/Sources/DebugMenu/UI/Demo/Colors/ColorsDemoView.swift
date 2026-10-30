import SharedUI
import SwiftUI

struct ColorsDemoView: View {
    private typealias Token = (name: String, color: Color)

    private var groups: [(title: String, tokens: [Token])] {
        [
            ("Content", [
                ("contentContentPrimary", theme.color.contentContentPrimary),
                ("contentContentSecondary", theme.color.contentContentSecondary),
                ("contentContentTerciary", theme.color.contentContentTerciary),
                ("contentContentPrimaryDisabled", theme.color.contentContentPrimaryDisabled),
                ("contentContentPrimaryActive", theme.color.contentContentPrimaryActive),
                ("contentContentInvertedPrimary", theme.color.contentContentInvertedPrimary),
                ("contentContentInvertedPrimarydisabled", theme.color.contentContentInvertedPrimarydisabled),
                ("contentContentPositive", theme.color.contentContentPositive),
                ("contentContentNegative", theme.color.contentContentNegative),
            ]),
            ("Surface", [
                ("surfaceBackgroundPrimary", theme.color.surfaceBackgroundPrimary),
                ("surfaceBackgroundPrimaryActive", theme.color.surfaceBackgroundPrimaryActive),
                ("surfaceBackgroundTerciary", theme.color.surfaceBackgroundTerciary),
                ("surfaceBackgroundInvertedPrimary", theme.color.surfaceBackgroundInvertedPrimary),
                ("surfaceForegroundPrimary", theme.color.surfaceForegroundPrimary),
                ("surfaceForegroundInvertedPrimary", theme.color.surfaceForegroundInvertedPrimary),
                ("surfaceBackgroundPositive", theme.color.surfaceBackgroundPositive),
                ("surfaceBackgroundNegative", theme.color.surfaceBackgroundNegative),
                ("surfaceBackgroundDestructive", theme.color.surfaceBackgroundDestructive),
            ]),
            ("Border", [
                ("borderSoft", theme.color.borderSoft),
                ("borderMedium", theme.color.borderMedium),
                ("borderStrong", theme.color.borderStrong),
            ]),
            ("Link", [
                ("linkLinkPrimaryDefault", theme.color.linkLinkPrimaryDefault),
                ("linkLinkPrimaryDisabled", theme.color.linkLinkPrimaryDisabled),
                ("linkLinkPrimaryInvertedDefault", theme.color.linkLinkPrimaryInvertedDefault),
                ("linkLinkPrimaryInvertedDisabled", theme.color.linkLinkPrimaryInvertedDisabled),
            ]),
            ("Button", [
                ("buttonPrimaryBackgroundPrimaryDefault", theme.color.buttonPrimaryBackgroundPrimaryDefault),
                ("buttonPrimaryContentPrimaryDefault", theme.color.buttonPrimaryContentPrimaryDefault),
                ("buttonSecondaryStrokeSecondaryDefault", theme.color.buttonSecondaryStrokeSecondaryDefault),
                ("buttonSecondaryContentSecondaryDefault", theme.color.buttonSecondaryContentSecondaryDefault),
                ("buttonTerciaryContentTerciaryDefault", theme.color.buttonTerciaryContentTerciaryDefault),
                (
                    "buttonDestructiveBackgroundDestructiveDefault",
                    theme.color.buttonDestructiveBackgroundDestructiveDefault
                ),
                ("buttonDestructiveContentDestructiveDefault", theme.color.buttonDestructiveContentDestructiveDefault),
                ("buttonPrimaryBackgroundPrimaryDisabled", theme.color.buttonPrimaryBackgroundPrimaryDisabled),
                ("buttonPrimaryContentPrimaryDisabled", theme.color.buttonPrimaryContentPrimaryDisabled),
            ]),
        ]
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
                .fill(token.color)
                .overlay {
                    RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
                        .stroke(theme.color.borderSoft, lineWidth: theme.sizing.borderBorderWeightDefault)
                }
                .frame(width: theme.sizing.iconsIconXlarge, height: theme.sizing.iconsIconXlarge)
            Text.build(theme.font.body.small("theme.color.\(token.name)"))
                .foregroundStyle(theme.color.contentContentPrimary)
        }
    }
}

#Preview {
    ColorsDemoView()
}
