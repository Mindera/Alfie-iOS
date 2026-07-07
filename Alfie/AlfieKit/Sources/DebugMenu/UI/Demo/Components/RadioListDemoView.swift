import SharedUI
import SwiftUI

private enum RadioListTestValue: String, CaseIterable {
    case selection1 = "Option 1"
    case selection2 = "Option 2"
    case selection3 = "Option 3"
    case selection4 = "Option 4"
    case selectionDisabled = "Option Disabled"
}

struct RadioListDemoView: View {
    @State private var selectedValue: RadioListTestValue?

    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Radio Buttons")
            RadioButtonList(
                values: RadioListTestValue.allCases,
                disabledValues: .constant([.selectionDisabled]),
                selectedValue: $selectedValue,
                verticalSpacing: Primitives.Spacing.spacing24
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Primitives.Spacing.spacing32)

            DemoHelper.demoSectionHeader(title: "Demo")
            HStack {
                Text.build(theme.font.body.small("Selected Value"))
                Spacer()
                Text.build(theme.font.body.small("" + (selectedValue?.rawValue ?? "None")))
            }
            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }
}

#Preview {
    RadioListDemoView()
}
