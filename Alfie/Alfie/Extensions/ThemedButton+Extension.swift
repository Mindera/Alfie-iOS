import StyleGuide
import SwiftUI

extension ThemedButton {
    init(
        localizableResource: LocalizedStringResource,
        type: ButtonType = .medium,
        style: ButtonTheme = .primary,
        leadingAsset: Icon? = nil,
        trailingAsset: Icon? = nil,
        isDisabled: Binding<Bool> = .constant(false),
        isLoading: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.init(
            text: String(localized: localizableResource),
            type: type,
            style: style,
            leadingAsset: leadingAsset,
            trailingAsset: trailingAsset,
            isDisabled: isDisabled,
            isLoading: isLoading,
            action: action
        )
    }
}
