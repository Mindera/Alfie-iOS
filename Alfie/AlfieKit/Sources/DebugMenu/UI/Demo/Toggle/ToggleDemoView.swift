import SharedUI
import SwiftUI

struct ToggleDemoView: View {
    @State private var isOn = false
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingMd) {
            DemoHelper.demoSectionHeader(title: "Toggle")

            ThemedToggleView(isOn: $isOn, isDisabled: $isDisabled) {
                Text.build(theme.font.body.small("This is a toggle"))
            }

            DemoHelper.demoSectionHeader(title: "Options")
                .padding(.top, theme.sizing.spacingSpacingXl)

            ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.body.small("Disable")) }

            Spacer()
        }
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }
}

#Preview {
    ToggleDemoView()
}
