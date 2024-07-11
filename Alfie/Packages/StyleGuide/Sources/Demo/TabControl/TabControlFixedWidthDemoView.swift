import SwiftUI

struct TabControlFixedWidthDemoView: View {
    @State private var theme = TabControl.Theme.light
    @State private var currentIndex: Int = 0
    @State private var numberOfOptions = 3
    @State private var padding: CGFloat = Spacing.space100
    @State private var showIcons = false
    private let options = ["Reviews", "Offers", "Delivery", "Promos"]
    private var themeOptions = TabControl.Theme.allCases
    private var currentOptions: [String] {
        Array(options.prefix(numberOfOptions))
    }
    var body: some View {
        VStack {
            TabControl(theme: theme,
                       configuration: .fixedSize(horizontalMargins: padding),
                       options: currentOptions.map { TabControl.TabOption(title: $0, image: showIcons ? Icon.checkmark.image : nil) },
                       currentIndex: $currentIndex)

            TabView(selection: $currentIndex) {
                ForEach(Array(currentOptions.enumerated()), id: \.0) { _, value in
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Colors.primary.mono300)
                        .overlay {
                            Text.build(theme.font.paragraph.bold(value))
                                .foregroundColor(.white)
                        }
                        .frame(width: 300, height: 350)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: 400, height: 450)

            VStack {
                ThemedToggleView(isOn: $showIcons) {
                    Text.build(theme.font.paragraph.normal("Show Icons"))
                }

                Text.build(theme.font.paragraph.normal("Theme:"))
                Picker(selection: $theme) {
                    ForEach(themeOptions, id: \.self) { tabTheme in
                        Text.build(theme.font.small.normal("\(tabTheme)".capitalized))
                    }
                } label: {
                }

                Text.build(theme.font.paragraph.normal("Number Of Options:"))
                Picker(selection: $numberOfOptions) {
                    ForEach(2...options.count, id: \.self) { optionCount in
                        Text.build(theme.font.small.normal("\(optionCount)"))
                    }
                } label: {
                }

                Text.build(theme.font.paragraph.normal("Horizontal Margins: \(Int(padding))"))
                Slider(value: $padding, in: 0...32)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.space300)
        }
    }
}

#Preview {
    TabControlIntrinsicWidthDemoView()
}
