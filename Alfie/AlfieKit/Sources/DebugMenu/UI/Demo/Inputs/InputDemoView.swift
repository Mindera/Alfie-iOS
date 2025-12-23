import SharedUI
import SwiftUI

struct InputDemoView: View {
    @State private var textA: String = ""
    @State private var textB: String = ""
    @State private var textC: String = ""
    @State private var textD: String = ""
    @State private var textE: String = ""
    @State private var isDisabled = false
    @State private var isRequired = false
    @State private var hasLimit = false
    @State private var hasIcon = false
    @State private var icon: Icon = .eye

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Input Fields")

                ThemedInput($textA, isDisabled: $isDisabled)
                ThemedInput(
                    $textB,
                    title: "Title",
                    placeholder: "E.g. John",
                    isDisabled: $isDisabled,
                    isRequired: $isRequired,
                    icon: iconSelected
                )
                ThemedInput(
                    $textC,
                    title: "Title",
                    status: .info("Must be at least 8 characters long and include 1 number."),
                    limit: textLimit,
                    isDisabled: $isDisabled,
                    isRequired: $isRequired,
                    icon: iconSelected
                )
                ThemedInput(
                    $textD,
                    title: "Title",
                    status: .success("Must be at least 8 characters long and include 1 number."),
                    limit: textLimit,
                    isDisabled: $isDisabled,
                    isRequired: $isRequired,
                    icon: iconSelected
                )
                ThemedInput(
                    $textE,
                    title: "Title",
                    status: .error("Must be at least 8 characters long and include 1 number."),
                    limit: textLimit,
                    isDisabled: $isDisabled,
                    isRequired: $isRequired,
                    icon: iconSelected
                )

                DemoHelper.demoSectionHeader(title: "Options")
                    .padding(.top, Spacing.space400)

                ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.small.bold("Disabled")) }
                ThemedToggleView(isOn: $isRequired) { Text.build(theme.font.small.bold("Required")) }
                ThemedToggleView(isOn: $hasLimit) { Text.build(theme.font.small.bold("Counter")) }
                ThemedToggleView(isOn: $hasIcon) { Text.build(theme.font.small.bold("Show Icon")) }
                HStack {
                    Text.build(theme.font.small.bold("Icon"))
                    Spacer()
                    Menu {
                        Picker(selection: $icon) {
                            ForEach(Icon.allCases, id: \.self) { icon in
                                Text(icon.rawValue)
                                    .tag(icon)
                            }
                        } label: {
                        }
                    } label: {
                        Text.build(theme.font.small.normal(icon.rawValue))
                            .tint(Colors.secondary.blue500)
                    }
                }
                .disabled(!hasIcon)
                .padding(.bottom, Spacing.space700)
            }
            .padding(.horizontal, Spacing.space200)
        }
        .onChange(of: hasLimit) { newValue in
            guard newValue, let textLimit else {
                return
            }

            textC = "\(textC.prefix(textLimit))"
            textD = "\(textD.prefix(textLimit))"
            textE = "\(textE.prefix(textLimit))"
        }
    }

    private var textLimit: Int? {
        hasLimit ? 30 : nil
    }

    private var iconSelected: Icon? {
        hasIcon ? icon : nil
    }
}

#Preview {
    InputDemoView()
}
