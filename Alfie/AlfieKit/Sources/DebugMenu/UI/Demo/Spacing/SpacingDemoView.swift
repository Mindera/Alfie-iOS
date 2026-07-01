import SharedUI
import SwiftUI

struct SpacingDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing20) {
                DemoHelper.demoSectionHeader(title: "Spacing")
                spacingView(token: "space.0", multiplier: "0.00", Primitives.Spacing.spacing0)
                spacingView(token: "space.025", multiplier: "0.25", Primitives.Spacing.spacing2)
                spacingView(token: "space.050", multiplier: "0.50", Primitives.Spacing.spacing4)
                spacingView(token: "space.100", multiplier: "1", Primitives.Spacing.spacing8)
                spacingView(token: "space.150", multiplier: "1.5", Primitives.Spacing.spacing12)
                spacingView(token: "space.200", multiplier: "2", Primitives.Spacing.spacing16)
                spacingView(token: "space.250", multiplier: "2.5", Primitives.Spacing.spacing20)
                spacingView(token: "space.300", multiplier: "3", Primitives.Spacing.spacing24)
                spacingView(token: "space.400", multiplier: "4", Primitives.Spacing.spacing32)
                spacingView(token: "space.500", multiplier: "5", Primitives.Spacing.spacing40)
                spacingView(token: "space.600", multiplier: "6", Primitives.Spacing.spacing48)
                spacingView(token: "space.700", multiplier: "7", Primitives.Spacing.spacing56)
                spacingView(token: "space.800", multiplier: "8", Primitives.Spacing.spacing64)
                spacingView(token: "space.1000", multiplier: "10", Primitives.Spacing.spacing80)
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }

    private func spacingView(token: String, multiplier: String, _ spacing: CGFloat) -> some View {
        Group {
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing0) {
                HStack {
                    Text.build(theme.font.paragraph.bold(token))
                    Text.build(theme.font.tiny.normal("\(Int(spacing))pt (Base Unit Multiplier: \(multiplier))"))
                    Spacer()
                }
                ThemedDivider.horizontalThick
                    .padding(.top, Primitives.Spacing.spacing2)

                Image(systemName: "arrow.down.to.line")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 16)
                    .background(.black)
                    .foregroundStyle(.white)
                    .padding(.top, Primitives.Spacing.spacing20)

                Spacer(minLength: spacing)

                Image(systemName: "arrow.up.to.line")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 16)
                    .background(.black)
                    .foregroundStyle(.white)
                    .padding(.bottom, Primitives.Spacing.spacing20)
            }
        }
    }
}

#Preview {
    SpacingDemoView()
}
