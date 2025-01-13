import SwiftUI

struct ChipsDemoView: View {
    @State private var isLarge = false
    @State private var isDisabled = false
    @State private var isSelected = false
    @State private var isCloseable = false
    @State private var counterValue: Int? = 1

    var body: some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Chips")
                .padding(.bottom, Spacing.space400)
            VStack(spacing: Spacing.space0) {
                Spacer()
                Chip(
                    configuration: .init(
                        type: isLarge ? .large : .small,
                        label: "Label",
                        counter: counterValue,
                        showCloseButton: isCloseable,
                        isDisabled: $isDisabled,
                        isSelected: $isSelected
                    ) { }
                )
                Spacer()
            }
            .frame(height: 50)
            .padding(.bottom, Spacing.space400)
            DemoHelper.demoSectionHeader(title: "Options")
            ThemedToggleView(isOn: $isLarge) { Text.build(theme.font.small.bold("Large")) }
            ThemedToggleView(isOn: $isCloseable) { Text.build(theme.font.small.bold("Closeable")) }
            ThemedToggleView(isOn: $isDisabled) { Text.build(theme.font.small.bold("Disabled")) }
            ThemedToggleView(isOn: $isSelected) { Text.build(theme.font.small.bold("Selected")) }

            DemoHelper.demoSectionHeader(title: "Counter")
                .padding(.top, 20)

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    ThemedButton(text: "Toggle") {
                        if counterValue != nil {
                            counterValue = nil
                        } else {
                            counterValue = 1
                        }
                    }

                    Spacer()
                    ThemedButton(text: "Max") { counterValue = 100 }
                    Spacer()
                    ThemedButton(text: "Min") { counterValue = 0 }
                    Spacer()
                }
                HStack {
                    Spacer()
                    ThemedButton(text: "Increase") {
                        if let currentValue = counterValue {
                            counterValue = min(currentValue + 1, 100)
                        } else {
                            counterValue = 0
                        }
                    }
                    Spacer()
                    ThemedButton(text: "Decrease") {
                        if let currentValue = counterValue {
                            counterValue = max(currentValue - 1, 0)
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.space200)
        .onChange(of: isSelected) { newValue in
            if newValue {
                isDisabled = false
            }
        }
        .onChange(of: isDisabled) { newValue in
            if newValue {
                isSelected = false
            }
        }
    }
}

#Preview {
    ChipsDemoView()
}
