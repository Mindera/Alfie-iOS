import SharedUI
import SwiftUI

struct ToggleDemoView: View {
    private var theme: ThemeProviderProtocol = ThemeProvider()
    @State private var isOn = false
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Toggle")

            ThemedToggleView(isOn: $isOn, isDisabled: $isDisabled) {
                Text.build(theme.font.small.bold("This is a toggle"))
            }

            DemoHelper.demoSectionHeader(title: "Options")
                .padding(.top, Primitives.Spacing.spacing32)

            ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.small.bold("Disable")) }

            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }
}

#Preview {
    ToggleDemoView()
}
