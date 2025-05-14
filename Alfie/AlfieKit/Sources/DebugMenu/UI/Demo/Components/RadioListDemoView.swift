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
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Radio Buttons")
            RadioButtonList(
                values: RadioListTestValue.allCases,
                disabledValues: .constant([.selectionDisabled]),
                selectedValue: $selectedValue,
                verticalSpacing: Spacing.space300
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Spacing.space400)

            DemoHelper.demoSectionHeader(title: "Demo")
            HStack {
                Text.build(theme.font.small.bold("Selected Value"))
                Spacer()
                Text.build(theme.font.small.normal("" + (selectedValue?.rawValue ?? "None")))
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.space200)
    }
}

#Preview {
    RadioListDemoView()
}
