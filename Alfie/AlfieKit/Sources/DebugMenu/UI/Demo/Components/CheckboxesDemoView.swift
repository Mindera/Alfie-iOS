import SharedUI
import SwiftUI

struct CheckboxesDemoView: View {
    @State private var enabledCheckboxState = CheckboxState.selected

    var body: some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Checkbox")
                .padding(.bottom, Primitives.Spacing.spacing32)
            Checkbox(
                state: $enabledCheckboxState,
                text: .constant(enabledCheckboxState == .selected ? "Selected" : "Unselected")
            )
            Checkbox(state: .constant(.disabled), text: "Disabled")
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }
}

#Preview {
    CheckboxesDemoView()
}
