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
        guard state == .available else {
            return .init(
                borderColor: DesignSystem.shared.color.borderSoft,
                borderWidth: Constants.borderWidthDefault,
                textColor: DesignSystem.shared.color.contentContentTerciary,
                backgroundColor: .clear
            )
        }

        return .init(
            borderColor: isSelected
                ? DesignSystem.shared.color.contentContentPrimary
                : DesignSystem.shared.color.borderSoft,
            borderWidth: isSelected ? Constants.borderWidthSelected : Constants.borderWidthDefault,
            textColor: DesignSystem.shared.color.contentContentPrimary,
            backgroundColor: .clear
        )
    }
}

private enum Constants {
    static let borderWidthDefault: CGFloat = 1
    static let borderWidthSelected: CGFloat = 2
}
