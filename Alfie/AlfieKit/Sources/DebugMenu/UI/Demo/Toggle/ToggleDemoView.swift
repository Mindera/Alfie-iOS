import SharedUI
import SwiftUI

struct ToggleDemoView: View {
    private var theme: DesignSystemProtocol = DesignSystem()
    @State private var isOn = false
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Toggle")

            ThemedToggleView(isOn: $isOn, isDisabled: $isDisabled) {
                Text.build(theme.font.body.small("This is a toggle"))
            }

            DemoHelper.demoSectionHeader(title: "Options")
                .padding(.top, Primitives.Spacing.spacing32)

            ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.body.small("Disable")) }

            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }
}

#Preview {
    ToggleDemoView()
}
