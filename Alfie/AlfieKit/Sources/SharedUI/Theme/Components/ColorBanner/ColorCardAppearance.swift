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

    /// Selection darkens the border and bolds the label — the stroke stays 1pt, unlike the size
    /// chip, and the swatch inside keeps its own unselected appearance so the marks never stack.
    public static func resolve(isSelected: Bool, isDisabled: Bool) -> Self {
        let colors = SwatchColors(isSelected: isSelected, isEnabled: !isDisabled)
        return .init(
            borderColor: colors.border,
            borderWidth: Constants.borderWidth,
            textColor: colors.text,
            isSelected: isSelected && !isDisabled
        )
    }
}

private enum Constants {
    static let borderWidth: CGFloat = 1
}
