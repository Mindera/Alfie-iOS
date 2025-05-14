import SharedUI
import SwiftUI

struct TypographyDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Typography")
                Spacer()
                headers
                paragraphs
                small
                tiny
            }
            .padding(.horizontal, Spacing.space200)
        }
    }

    private var headers: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Heading")

            Text.build(theme.font.header.h1("Heading 1"))
            Text.build(theme.font.header.h2("Heading 2"))
            Text.build(theme.font.header.h3("Heading 3"))
        }
    }

    private var paragraphs: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Paragraph")

            Text.build(theme.font.paragraph.normal("Paragraph"))
            Text.build(theme.font.paragraph.italic("Paragraph Italic"))
            Text.build(theme.font.paragraph.normalUnderline("Paragraph Underline"))
            Text.build(theme.font.paragraph.normalStrike("Paragraph Strikethrough"))
            Text.build(theme.font.paragraph.bold("Paragraph Bold"))
            Text.build(theme.font.paragraph.boldItalic("Paragraph Bold Italic"))
            Text.build(theme.font.paragraph.boldUnderline("Paragraph Bold Underline"))
            Text.build(theme.font.paragraph.boldStrike("Paragraph Bold Strikethrough"))
        }
    }

    private var small: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Small")

            Text.build(theme.font.small.normal("Small"))
            Text.build(theme.font.small.italic("Small Italic"))
            Text.build(theme.font.small.normalUnderline("Small Underline"))
            Text.build(theme.font.small.normalStrike("Small Strikethrough"))
            Text.build(theme.font.small.bold("Small Bold"))
            Text.build(theme.font.small.boldItalic("Small Bold Italic"))
            Text.build(theme.font.small.boldUnderline("Small Bold Underline"))
            Text.build(theme.font.small.boldStrike("Small Bold Strikethrough"))
        }
    }

    private var tiny: some View {
        VStack(alignment: .leading) {
            DemoHelper.demoSectionHeader(title: "Tiny")

            Text.build(theme.font.tiny.normal("Tiny"))
            Text.build(theme.font.tiny.italic("Tiny Italic"))
            Text.build(theme.font.tiny.bold("Tiny Bold"))
            Text.build(theme.font.tiny.boldItalic("Tiny Bold Italic"))
            Text.build(theme.font.tiny.boldUnderline("Tiny Bold Underline"))
        }
    }
}

#Preview {
    TypographyDemoView()
}
