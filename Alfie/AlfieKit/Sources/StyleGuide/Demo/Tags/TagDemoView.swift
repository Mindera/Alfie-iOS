import SwiftUI

struct TagDemoView: View {
    @State private var tags: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Tag")

                HStack {
                    Text.build(theme.font.small.bold("Simple"))
                    Spacer()
                    Tag(configuration: .init(label: "Label"))
                }
                HStack {
                    Text.build(theme.font.small.bold("With close"))
                    Spacer()
                    Tag(configuration: .init(label: "Label", showCloseButton: true))
                }
                HStack {
                    Text.build(theme.font.small.bold("With icon"))
                    Spacer()
                    Tag(configuration: .init(label: "Label", showCloseButton: false, icon: Icon.info.image))
                }
                HStack {
                    Text.build(theme.font.small.bold("Full"))
                    Spacer()
                    Tag(configuration: .init(label: "Label", showCloseButton: true, icon: Icon.info.image))
                }
                Spacer()

                DemoHelper.demoSectionHeader(title: "Demo")

                ThemedButton(text: "Add Tag") {
                    var newTag = generateTag()
                    while tags.contains(newTag) {
                        newTag = generateTag()
                    }
                    tags.append(newTag)
                }

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Spacing.space150) {
                    ForEach(tags, id: \.self) { tag in
                        Tag(configuration: .init(label: tag, showCloseButton: true) { tags.removeAll { $0 == tag } })
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
        }
    }

    private func generateTag() -> String {
        "Tag \(UUID().uuidString.prefix(2))"
    }
}

#Preview {
    TagDemoView()
}
