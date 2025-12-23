import SharedUI
import SwiftUI

struct SpacingDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Spacing")
                spacingView(token: "space.0", multiplier: "0.00", Spacing.space0)
                spacingView(token: "space.025", multiplier: "0.25", Spacing.space025)
                spacingView(token: "space.050", multiplier: "0.50", Spacing.space050)
                spacingView(token: "space.075", multiplier: "0.75", Spacing.space075)
                spacingView(token: "space.100", multiplier: "1", Spacing.space100)
                spacingView(token: "space.150", multiplier: "1.5", Spacing.space150)
                spacingView(token: "space.200", multiplier: "2", Spacing.space200)
                spacingView(token: "space.250", multiplier: "2.5", Spacing.space250)
                spacingView(token: "space.300", multiplier: "3", Spacing.space300)
                spacingView(token: "space.400", multiplier: "4", Spacing.space400)
                spacingView(token: "space.500", multiplier: "5", Spacing.space500)
                spacingView(token: "space.600", multiplier: "6", Spacing.space600)
                spacingView(token: "space.700", multiplier: "7", Spacing.space700)
                spacingView(token: "space.800", multiplier: "8", Spacing.space800)
                spacingView(token: "space.900", multiplier: "9", Spacing.space900)
                spacingView(token: "space.1000", multiplier: "10", Spacing.space1000)
            }
            .padding(.horizontal, Spacing.space200)
        }
    }

    private func spacingView(token: String, multiplier: String, _ spacing: CGFloat) -> some View {
        Group {
            VStack(alignment: .leading, spacing: Spacing.space0) {
                HStack {
                    Text.build(theme.font.paragraph.bold(token))
                    Text.build(theme.font.tiny.normal("\(Int(spacing))pt (Base Unit Multiplier: \(multiplier))"))
                    Spacer()
                }
                ThemedDivider.horizontalThick
                    .padding(.top, Spacing.space025)

                Image(systemName: "arrow.down.to.line")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 16)
                    .background(.black)
                    .foregroundStyle(.white)
                    .padding(.top, Spacing.space250)

                Spacer(minLength: spacing)

                Image(systemName: "arrow.up.to.line")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 16)
                    .background(.black)
                    .foregroundStyle(.white)
                    .padding(.bottom, Spacing.space250)
            }
        }
    }
}

#Preview {
    SpacingDemoView()
}
