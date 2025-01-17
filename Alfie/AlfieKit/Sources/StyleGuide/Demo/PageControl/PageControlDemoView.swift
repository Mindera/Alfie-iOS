import SwiftUI

struct PageControlDemoView: View {
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Progress Indicators")

            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text.build(theme.font.small.bold("Small Dots"))
                            .frame(height: 30, alignment: .leading)

                        Text.build(theme.font.small.bold("Medium Dots"))
                            .frame(height: 30, alignment: .leading)

                        Text.build(theme.font.small.bold("Large Dots"))
                            .frame(height: 30, alignment: .leading)

                        Text.build(theme.font.small.bold("Custom Dots"))
                            .frame(height: 30, alignment: .leading)
                    }
                    Spacer()
                    VStack {
                        ThemedPageControl(
                            data: [0, 1, 2],
                            selectedIndex: $selectedIndex,
                            configuration: .init(size: 8, spacing: 5)
                        )
                        .frame(height: 30, alignment: .leading)
                        ThemedPageControl(
                            data: [0, 1, 2],
                            selectedIndex: $selectedIndex,
                            configuration: .init(size: 12, spacing: 5)
                        )
                        .frame(height: 30, alignment: .leading)
                        ThemedPageControl(
                            data: [0, 1, 2],
                            selectedIndex: $selectedIndex,
                            configuration: .init(size: 16, spacing: 5)
                        )
                        .frame(height: 30, alignment: .leading)
                        ThemedPageControl(
                            data: [0, 1, 2],
                            selectedIndex: $selectedIndex,
                            configuration: .init(size: 16, spacing: 5)
                        ) { _, isSelected in
                            let configuration = ThemedPageControlConfiguration(size: 16)
                            Rectangle()
                                .fill(isSelected ? configuration.selectedColor : configuration.color)
                                .frame(width: configuration.size, height: configuration.size)
                                .animation(.linear(duration: configuration.animationDuration), value: isSelected)
                        }
                        .frame(height: 30, alignment: .leading)
                    }
                }
            }
            DemoHelper.demoSectionHeader(title: "Options")
                .padding(.top, Spacing.space400)
            HStack(spacing: Spacing.space250) {
                selectionButton(title: "First", selectedIndex: 0)
                selectionButton(title: "Second", selectedIndex: 1)
                selectionButton(title: "Third", selectedIndex: 2)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.space200)
    }

    private func selectionButton(title: String, selectedIndex: Int) -> some View {
        ThemedButton(text: title) { self.selectedIndex = selectedIndex }
    }
}

#Preview {
    PageControlDemoView()
}
