import SharedUI
import SwiftUI

// swiftlint:disable line_length
struct AccordionDemoView: View {
    @State private var isDisabled = false
    var body: some View {
        ScrollView {
            VStack(spacing: theme.sizing.spacingSpacingMd) {
                DemoHelper.demoSectionHeader(title: "Accordion - Small")

                VStack(spacing: theme.sizing.spacingSpacingNone) {
                    AccordionView(text: "Section One", isDisabled: $isDisabled) {
                        Text.build(theme.font.body.small("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet."))
                    }
                    AccordionView(text: "Section Two", isDisabled: $isDisabled, notFirst: true) {
                        Text.build(theme.font.body.small("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet."))
                    }
                }

                DemoHelper.demoSectionHeader(title: "Accordion - Large")
                    .padding(.top, theme.sizing.spacingSpacingXl)

                VStack(spacing: theme.sizing.spacingSpacingNone) {
                    AccordionView(text: "Section One", type: .large, isDisabled: $isDisabled) {
                        Text.build(theme.font.body.small("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet."))
                    }
                    AccordionView(text: "Section Two", type: .large, isDisabled: $isDisabled, notFirst: true) {
                        Text.build(theme.font.body.small("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus, accumsan, vel interdum diam tortor cursus nam quisque ut. Blandit ut netus consequat ridiculus mi. Lacus a fermentum nec nisl consectetur molestie. Mauris mi cursus quis risus aliquam vivamus blandit. Maecenas dui odio odio aliquet."))
                    }
                }

                DemoHelper.demoSectionHeader(title: "Options")
                    .padding(.top, theme.sizing.spacingSpacingXl)
                ThemedToggleView(isOn: $isDisabled) {
                    Text.build(theme.font.body.medium("Disabled"))
                }
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
    }
}
// swiftlint:enable line_length

#Preview {
    AccordionDemoView()
}
