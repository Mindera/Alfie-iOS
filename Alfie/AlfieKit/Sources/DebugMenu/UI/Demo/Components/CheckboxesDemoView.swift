import SharedUI
import SwiftUI

struct CheckboxesDemoView: View {
    @State private var enabledCheckboxState = CheckboxState.selected

    var body: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingMd) {
            DemoHelper.demoSectionHeader(title: "Checkbox")
                .padding(.bottom, theme.sizing.spacingSpacingXl)
            Checkbox(
                state: $enabledCheckboxState,
                text: .constant(enabledCheckboxState == .selected ? "Selected" : "Unselected")
            )
            Checkbox(state: .constant(.disabled), text: "Disabled")
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }
}

#Preview {
    CheckboxesDemoView()
}
