import SharedUI
import SwiftUI

struct LoadingDemoView: View {
    @State private var number: Double = 20
    @State private var showLabel = true

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                componentPreview(
                    LoaderView(circleDiameter: .defaultSmall, labelHidden: !showLabel),
                    title: "Loading - Default",
                    description: "",
                    showStepper: false
                )
                componentPreview(
                    LoaderView(circleDiameter: .custom(number), labelHidden: !showLabel),
                    title: "Loading - Custom",
                    showStepper: true
                )

                VStack(spacing: Spacing.space200) {
                    DemoHelper.demoSectionHeader(title: "Loading - Logo")
                    ThemedLoaderView(labelHidden: !showLabel)
                }

                DemoHelper.demoSectionHeader(title: "Options")
                    .padding(.top, Spacing.space250)
                ThemedToggleView(isOn: $showLabel) { Text.build(theme.font.paragraph.normal("Show loading label")) }

                Stepper(value: $number, in: 1...100, step: 4) {
                    Text.build(theme.font.small.bold("Custom size"))
                }
            }
            .padding(Spacing.space200)
        }
        .navigationTitle("Loading")
    }

    private func componentPreview(_ component: some View, title: String, description: String = "", showStepper: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space0) {
            HStack {
                Text.build(theme.font.paragraph.bold(title))
                Spacer()

                if showStepper {
                    Text.build(theme.font.tiny.normal("Size: \(Int(number))"))
                } else {
                    Text.build(theme.font.tiny.normal(description))
                }
            }

            ThemedDivider.horizontalThick
                .padding(.top, Spacing.space025)

            component
                .padding(.vertical, Spacing.space250)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    LoadingDemoView()
}
