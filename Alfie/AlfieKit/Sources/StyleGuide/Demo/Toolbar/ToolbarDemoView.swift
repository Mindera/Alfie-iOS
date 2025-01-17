import SwiftUI

struct ToolbarDemoView: View {
    private enum ToolbarButtonMode: String, CaseIterable {
        case singleIcon = "Single Icon"
        case singleText = "Single Text"
        case multiIcon = "Multiple Icon"
        case multiText = "Multiple Text"
        case multiMixed = "Multiple Mixed"
        case hidden = "None"

        var isIcon: Bool {
            [.singleIcon, .multiIcon, .multiMixed].contains(self)
        }

        var isText: Bool {
            [.singleText, .multiText].contains(self)
        }

        var isMulti: Bool {
            [.multiIcon, .multiText, .multiMixed].contains(self)
        }
    }

    // TODO: replace usage of dismiss with a coordinator, here and in other demo views (not possible for now, as we have a crash due to a missing env obj, to be fixed later)
    @Environment(\.dismiss) private var dismiss
    @State private var showLogo = true
    @State private var alwaysShowDivider = true
    @State private var darkMode = false
    @State private var leftAlign = false
    @State private var rightMode: ToolbarButtonMode? = .multiIcon
    @State private var leftMode: ToolbarButtonMode? = .singleIcon

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                DemoHelper.demoHeader(title: "Catalogue App")
                    .padding(.vertical, Spacing.space050)

                DemoHelper.demoSectionHeader(title: "Title Header")
                    .padding(.bottom, Spacing.space250)

                DemoHelper.demoSectionHeader(title: "Title")

                ThemedToggleView(isOn: $showLogo) { Text.build(theme.font.small.bold("Show logo")) }

                ThemedToggleView(isOn: $leftAlign) { Text.build(theme.font.small.bold("Show nav title")) }

                ThemedToggleView(isOn: $alwaysShowDivider, isDisabled: $darkMode) {
                    Text.build(theme.font.small.bold("Always show divider"))
                }

                ThemedToggleView(isOn: $darkMode) { Text.build(theme.font.small.bold("Dark mode")) }

                DemoHelper.demoSectionHeader(title: "Controls (Left / Right)")
                    .padding(.top, Spacing.space250)

                HStack(spacing: Spacing.space0) {
                    RadioButtonList(
                        values: ToolbarButtonMode.allCases,
                        disabledValues: .constant([]),
                        selectedValue: $leftMode,
                        verticalSpacing: Spacing.space300
                    )

                    Spacer()

                    RadioButtonList(
                        values: ToolbarButtonMode.allCases,
                        disabledValues: .constant([]),
                        selectedValue: $rightMode,
                        verticalSpacing: Spacing.space300
                    )
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
        }
        .toolbar {
            leadingToolbarContent
            principalToolbarContent
            trailingToolbarContent
        }
        .onChange(of: leftAlign) { newValue in
            if newValue {
                showLogo = false
            }
        }
        .onChange(of: showLogo) { newValue in
            if newValue {
                leftAlign = false
            }
        }
        .toolbarBackground(darkMode ? Colors.primary.mono900 : Colors.primary.white)
        .toolbarBackground(alwaysShowDivider ? .visible : .automatic, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onChange(of: darkMode) { newValue in
            if newValue {
                alwaysShowDivider = true
            }
        }
    }

    private var leadingToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            if leftAlign {
                ThemedToolbarTitle(
                    style: .leftText("Alfie"),
                    tint: !darkMode ? Colors.primary.mono900 : Colors.primary.white
                )
            } else {
                if let mode = leftMode, mode != .hidden {
                    ThemedToolbarButton(
                        icon: mode.isIcon ? .arrowLeft : nil,
                        text: mode.isText ? "Back" : nil,
                        tint: darkMode ? Colors.primary.white : Colors.primary.mono900
                    ) { dismiss() }

                    if mode.isMulti {
                        ThemedToolbarButton(
                            icon: mode.isIcon && mode != .multiMixed ? .store : nil,
                            text: mode.isText || mode == .multiMixed ? "Shop" : nil,
                            tint: darkMode ? Colors.primary.white : Colors.primary.mono900
                        ) {}
                    }
                }
            }
        }
    }

    private var principalToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if leftAlign {
                Spacer()
            } else {
                ThemedToolbarTitle(
                    style: showLogo ? .logo : .text("Alfie"),
                    tint: darkMode ? Colors.primary.white : Colors.primary.mono900
                )
            }
        }
    }

    private var trailingToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if let mode = rightMode, mode != .hidden {
                ThemedToolbarButton(
                    icon: mode.isIcon ? .bag : nil,
                    text: mode.isText ? "Bag" : nil,
                    tint: darkMode ? Colors.primary.white : Colors.primary.mono900
                ) {}

                if mode.isMulti {
                    ThemedToolbarButton(
                        icon: mode.isIcon && mode != .multiMixed ? .chat : nil,
                        text: mode.isText || mode == .multiMixed ? "Chat" : nil,
                        tint: darkMode ? Colors.primary.white : Colors.primary.mono900
                    ) {}
                }
            }
        }
    }
}

#Preview {
    ToolbarDemoView()
}
