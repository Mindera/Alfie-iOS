import SharedUI
import SwiftUI

struct TagDemoView: View {
    @State private var tags: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Primitives.Spacing.spacing20) {
                DemoHelper.demoSectionHeader(title: "Tag")

                HStack {
                    Text.build(theme.font.body.small("Simple"))
                    Spacer()
                    Tag(configuration: .init(label: "Label"))
                }
                HStack {
                    Text.build(theme.font.body.small("With close"))
                    Spacer()
                    Tag(configuration: .init(label: "Label", showCloseButton: true))
                }
                HStack {
                    Text.build(theme.font.body.small("With icon"))
                    Spacer()
                    Tag(configuration: .init(label: "Label", showCloseButton: false, icon: Icon.info.image))
                }
                HStack {
                    Text.build(theme.font.body.small("Full"))
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

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Primitives.Spacing.spacing12) {
                    ForEach(tags, id: \.self) { tag in
                        Tag(configuration: .init(label: tag, showCloseButton: true) { tags.removeAll { $0 == tag } })
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }

    private func generateTag() -> String {
        "Tag \(UUID().uuidString.prefix(2))"
    }
}

#Preview {
    TagDemoView()
}
