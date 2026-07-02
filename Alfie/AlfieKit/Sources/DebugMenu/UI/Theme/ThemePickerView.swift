import AccessibilityIdentifiers
import SharedUI
import SwiftUI

struct ThemePickerView: View {
    private let viewModel: ThemePickerViewModel

    init(viewModel: ThemePickerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.themes, id: \.self) { appTheme in
            Button {
                viewModel.select(appTheme)
            } label: {
                HStack {
                    Text.build(theme.font.body.small(viewModel.displayName(for: appTheme)))
                    Spacer()
                    if viewModel.isSelected(appTheme) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Primitives.Colours.neutrals800)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.DebugMenu.themeOption(id: appTheme.rawValue))
        }
        .listStyle(.plain)
        .accessibilityIdentifier(AccessibilityID.DebugMenu.themePicker)
    }
}
