import SwiftUI

struct CheckboxesDemoView: View {
    @State private var enabledCheckboxState = CheckboxState.selected

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Checkbox")
                .padding(.bottom, Spacing.space400)
            Checkbox(
                state: $enabledCheckboxState,
                text: .constant(enabledCheckboxState == .selected ? "Selected" : "Unselected")
            )
            Checkbox(state: .constant(.disabled), text: "Disabled")
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.space200)
    }
}

#Preview {
    CheckboxesDemoView()
}
