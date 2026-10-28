import SharedUI
import SwiftUI

struct InputDemoView: View {
    @State private var textA: String = ""
    @State private var textB: String = ""
    @State private var textC: String = ""
    @State private var textD: String = ""
    @State private var textE: String = ""
    @State private var isDisabled = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingMd) {
                DemoHelper.demoSectionHeader(title: "Input Fields")

                Group {
                    TextInput(configuration: .init(text: $textA))
                    TextInput(configuration: .init(text: $textB, label: "Title", placeholder: "E.g. John"))
                    TextInput(
                        configuration: .init(
                            text: $textC,
                            label: "Price",
                            placeholder: "0",
                            prefix: "£",
                            keyboardType: .numberPad
                        )
                    )
                    TextInput(
                        configuration: .init(text: $textD, label: "Title", placeholder: "E.g. John", isError: true)
                    )
                    TextInput(
                        configuration: .init(text: $textE, label: "Password", placeholder: "Password", isSecure: true)
                    )
                }
                .disabled(isDisabled)

                DemoHelper.demoSectionHeader(title: "Options")
                    .padding(.top, theme.sizing.spacingSpacingXl)

                ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.body.small("Disabled")) }
                    .padding(.bottom, theme.sizing.spacingSpacing2xl)
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
    }
}

#Preview {
    InputDemoView()
}
