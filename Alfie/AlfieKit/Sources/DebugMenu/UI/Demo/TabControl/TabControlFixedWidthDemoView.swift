import SharedUI
import SwiftUI

struct TabControlFixedWidthDemoView: View {
    @State private var tabTheme = TabControl.Style.light
    @State private var currentIndex: Int = 0
    @State private var numberOfOptions = 3
    @State private var padding: CGFloat = DesignSystem.shared.sizing.spacingSpacingXs
    @State private var showIcons = false
    private let options = ["Reviews", "Offers", "Delivery", "Promos"]
    private var themeOptions = TabControl.Style.allCases
    private var currentOptions: [String] {
        Array(options.prefix(numberOfOptions))
    }
    var body: some View {
        VStack {
            TabControl(
                style: tabTheme,
                configuration: .fixedSize(horizontalMargins: padding),
                options: currentOptions.map {
                    TabControl.TabOption(title: $0, image: showIcons ? Icon.checkmark.image : nil)
                },
                currentIndex: $currentIndex
            )

            TabView(selection: $currentIndex) {
                ForEach(Array(currentOptions.enumerated()), id: \.0) { _, value in
                    RoundedRectangle(cornerRadius: 25)
                        .fill(theme.color.borderStrong)
                        .overlay {
                            Text.build(theme.font.body.medium(value))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 300, height: 350)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: 400, height: 450)

            VStack {
                ThemedToggleView(isOn: $showIcons) {
                    Text.build(theme.font.body.medium("Show Icons"))
                }

                Text.build(theme.font.body.medium("Theme:"))
                Picker(selection: $tabTheme) {
                    ForEach(themeOptions, id: \.self) { tabTheme in
                        Text.build(theme.font.body.small("\(tabTheme)".capitalized))
                    }
                } label: {
                }

                Text.build(theme.font.body.medium("Number Of Options:"))
                Picker(selection: $numberOfOptions) {
                    ForEach(2...options.count, id: \.self) { optionCount in
                        Text.build(theme.font.body.small("\(optionCount)"))
                    }
                } label: {
                }

                Text.build(theme.font.body.medium("Horizontal Margins: \(Int(padding))"))
                Slider(value: $padding, in: 0...32)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, theme.sizing.spacingSpacingLg)
        }
    }
}

#Preview {
    TabControlIntrinsicWidthDemoView()
}
