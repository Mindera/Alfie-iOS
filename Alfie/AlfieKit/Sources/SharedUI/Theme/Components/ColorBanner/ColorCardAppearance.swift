import SwiftUI

/// Resolved appearance of one colour card, kept apart from the view so the state-to-style mapping is
/// assertable without rendering.
public struct ColorCardAppearance: Equatable {
    public let borderColor: Color
    public let borderWidth: CGFloat
    public let textColor: Color
    /// What the card actually draws as selected — the source for the accessibility trait too, so a
    /// card can never announce a selection it does not show.
    public let isSelected: Bool

    /// Selection is a heavier *border* on the card, matching the size chip — the swatch inside keeps
    /// its own unselected appearance so the two selection marks never stack.
    public static func resolve(isSelected: Bool, isDisabled: Bool) -> Self {
        guard !isDisabled else {
            return .init(
                borderColor: Theme.borderSoft,
                borderWidth: Constants.borderWidthDefault,
                textColor: Theme.contentContentTerciary,
                isSelected: false
            )
        }

        return .init(
            borderColor: isSelected ? Theme.contentContentPrimary : Theme.borderSoft,
            borderWidth: isSelected ? Constants.borderWidthSelected : Constants.borderWidthDefault,
            textColor: Theme.contentContentPrimary,
            isSelected: isSelected
        )
    }
}

private enum Constants {
    static let borderWidthDefault: CGFloat = 1
    static let borderWidthSelected: CGFloat = 2
}
