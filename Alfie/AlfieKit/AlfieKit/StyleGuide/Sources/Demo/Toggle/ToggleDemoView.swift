import SwiftUI

struct ToggleDemoView: View {
    private var theme: ThemeProviderProtocol = ThemeProvider()
    @State private var isOn = false
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Toggle")

            ThemedToggleView(isOn: $isOn, isDisabled: $isDisabled) {
                Text.build(theme.font.small.bold("This is a toggle"))
            }

            DemoHelper.demoSectionHeader(title: "Options")
                .padding(.top, Spacing.space400)

            ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.small.bold("Disable")) }

            Spacer()
        }
        .padding(.horizontal, Spacing.space200)
    }
}

#Preview {
    ToggleDemoView()
}
