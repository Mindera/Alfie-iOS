import SharedUI
import SwiftUI

struct TypographyDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Primitives.Spacing.spacing20) {
                DemoHelper.demoSectionHeader(title: "Typography")
                Spacer()
                display
                heading
                bodySection
                label
                link
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }

    private var display: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Display")

            Text.build(theme.font.display.large("Display Large"))
            Text.build(theme.font.display.medium("Display Medium"))
            Text.build(theme.font.display.small("Display Small"))
        }
    }

    private var heading: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Heading")

            Text.build(theme.font.heading.large("Heading Large"))
            Text.build(theme.font.heading.medium("Heading Medium"))
            Text.build(theme.font.heading.small("Heading Small"))
            Text.build(theme.font.heading.xSmall("Heading XSmall"))
        }
    }

    private var bodySection: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Body")

            Text.build(theme.font.body.large("Body Large"))
            Text.build(theme.font.body.medium("Body Medium"))
            Text.build(theme.font.body.medium("Body Medium Underline", underline: true))
            Text.build(theme.font.body.medium("Body Medium Strikethrough", strike: true))
            Text.build(theme.font.body.mediumStrikethrough("Body Medium Strikethrough Token"))
            Text.build(theme.font.body.small("Body Small"))
            Text.build(theme.font.body.small("Body Small Underline", underline: true))
            Text.build(theme.font.body.small("Body Small Strikethrough", strike: true))
        }
    }

    private var label: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Label")

            Text.build(theme.font.label.small("Label Small"))
            Text.build(theme.font.label.smallBold("Label Small Bold"))
        }
    }

    private var link: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Link")

            Text.build(theme.font.link.medium("Link Medium"))
            Text.build(theme.font.link.small("Link Small"))
        }
    }
}

#Preview {
    TypographyDemoView()
}
