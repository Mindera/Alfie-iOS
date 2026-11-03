import Model
import SwiftUI

/// Resolved appearance of one size chip, kept apart from the view so the state-to-style mapping is
/// assertable without rendering.
public struct SizingSwatchAppearance: Equatable {
    public let borderColor: Color
    public let borderWidth: CGFloat
    public let textColor: Color
    public let backgroundColor: Color

    /// Selection is a heavier *border* — never a fill, which is what the pre-redesign chip did.
    public static func resolve(for state: SizingSwatch.ItemState, isSelected: Bool) -> Self {
        let isAvailable = state == .available
        let colors = SwatchColors(isSelected: isSelected, isEnabled: isAvailable)
        return .init(
            borderColor: colors.border,
            borderWidth: isAvailable && isSelected ? Constants.borderWidthSelected : Constants.borderWidthDefault,
            textColor: colors.text,
            backgroundColor: .clear
        )
    }
}

private enum Constants {
    static let borderWidthDefault: CGFloat = 1
    static let borderWidthSelected: CGFloat = 2
}
