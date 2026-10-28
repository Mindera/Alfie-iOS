import SharedUI
import SwiftUI

struct ButtonDemoView: View {
    @State private var text = "Example Text"
    @State private var style: ButtonTheme = .primary
    @State private var showIconLeft = false
    @State private var iconLeft: Icon = .chevronLeft
    @State private var showIconRight = false
    @State private var iconRight: Icon = .chevronRight
    @State private var isDisabled = false
    @State private var isLoading = false
    @State private var isFullWidth = false

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingMd) {
            DemoHelper.demoSectionHeader(title: "Button")

            ThemedButton(
                text: text,
                type: .small,
                style: style,
                leadingAsset: showIconLeft ? iconLeft : nil,
                trailingAsset: showIconRight ? iconRight : nil,
                isDisabled: $isDisabled,
                isLoading: $isLoading,
                isFullWidth: isFullWidth
            ) {}
            .padding(.vertical, theme.sizing.spacingSpacingXs)

            ThemedButton(
                text: text,
                type: .medium,
                style: style,
                leadingAsset: showIconLeft ? iconLeft : nil,
                trailingAsset: showIconRight ? iconRight : nil,
                isDisabled: $isDisabled,
                isLoading: $isLoading,
                isFullWidth: isFullWidth
            ) {}
            .padding(.vertical, theme.sizing.spacingSpacingXs)

            ThemedButton(
                text: text,
                type: .big,
                style: style,
                leadingAsset: showIconLeft ? iconLeft : nil,
                trailingAsset: showIconRight ? iconRight : nil,
                isDisabled: $isDisabled,
                isLoading: $isLoading,
                isFullWidth: isFullWidth
            ) {}
            .padding(.vertical, theme.sizing.spacingSpacingXs)

            DemoHelper.demoSectionHeader(title: "Options")

            HStack {
                Text.build(theme.font.body.small("Caption"))
                Spacer()
                TextInput(configuration: .init(text: $text))
                    .padding(.leading, theme.sizing.spacingSpacing2xl)
            }

            HStack {
                Text.build(theme.font.body.small("Style"))
                Spacer()
                Menu {
                    Picker(selection: $style) {
                        ForEach(ButtonTheme.allCases, id: \.self) { buttonTheme in
                            Text(buttonTheme.rawValue)
                                .tag(buttonTheme)
                        }
                    } label: {
                    }
                } label: {
                    Text.build(theme.font.body.small(style.rawValue))
                        .tint(theme.color.borderStrong)
                }
            }

            ThemedToggleView(isOn: $showIconLeft) {
                Text.build(theme.font.body.small("Icon on the left"))
            }

            HStack {
                Text.build(theme.font.body.small("Icon"))
                Spacer()
                Menu {
                    Picker(selection: $iconLeft) {
                        ForEach(Icon.allCases, id: \.self) { icon in
                            Text(icon.rawValue)
                                .tag(icon)
                        }
                    } label: {
                    }
                } label: {
                    Text.build(theme.font.body.small(iconLeft.rawValue))
                        .tint(theme.color.borderStrong)
                }
            }
            .disabled(!showIconLeft)

            ThemedToggleView(isOn: $showIconRight) {
                Text.build(theme.font.body.small("Icon on the right"))
            }

            HStack {
                Text.build(theme.font.body.small("Icon"))
                Spacer()
                Menu {
                    Picker(selection: $iconRight) {
                        ForEach(Icon.allCases, id: \.self) { icon in
                            Text(icon.rawValue)
                                .tag(icon)
                        }
                    } label: {
                    }
                } label: {
                    Text.build(theme.font.body.small(iconRight.rawValue))
                        .tint(theme.color.borderStrong)
                }
            }
            .disabled(!showIconRight)

            ThemedToggleView(isOn: $isDisabled) {
                Text.build(theme.font.body.small("Disabled"))
            }

            ThemedToggleView(isOn: $isLoading) {
                Text.build(theme.font.body.small("Loading"))
            }

            ThemedToggleView(isOn: $isFullWidth) {
                Text.build(theme.font.body.small("Full width"))
            }

            Spacer()
        }
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }
}

#Preview {
    ButtonDemoView()
}
