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
        VStack(spacing: theme.sizing.spacingSpacingMd) {
            DemoHelper.demoSectionHeader(title: "Radio Buttons")
            RadioButtonList(
                values: RadioListTestValue.allCases,
                disabledValues: .constant([.selectionDisabled]),
                selectedValue: $selectedValue,
                verticalSpacing: theme.sizing.spacingSpacingLg
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, theme.sizing.spacingSpacingXl)

            DemoHelper.demoSectionHeader(title: "Demo")
            HStack {
                Text.build(theme.font.body.small("Selected Value"))
                Spacer()
                Text.build(theme.font.body.small("" + (selectedValue?.rawValue ?? "None")))
            }
            Spacer()
        }
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }
}

#Preview {
    RadioListDemoView()
}
