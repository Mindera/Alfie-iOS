import Model
import SwiftUI

/// Resolved appearance of one size chip, kept apart from the view so the state-to-style mapping is
/// assertable without rendering.
public struct SizingSwatchAppearance: Equatable {
    public let borderColor: Color
    public let borderWidth: CGFloat
    public let textColor: Color
    public let backgroundColor: Color
    /// Drives both out-of-stock marks the design draws: the diagonal line across the chip and the
    /// bell in its corner.
    public let isCrossedOut: Bool

    /// Selection is a heavier *border* — never a fill, which is what the pre-redesign chip did.
    public static func resolve(for state: SizingSwatch.ItemState, isSelected: Bool) -> Self {
        guard state == .available else {
            return .init(
                borderColor: Theme.borderSoft,
                borderWidth: Constants.borderWidthDefault,
                textColor: Theme.contentContentTerciary,
                backgroundColor: .clear,
                isCrossedOut: state == .outOfStock
            )
        }

        return .init(
            borderColor: isSelected ? Theme.contentContentPrimary : Theme.borderSoft,
            borderWidth: isSelected ? Constants.borderWidthSelected : Constants.borderWidthDefault,
            textColor: Theme.contentContentPrimary,
            backgroundColor: .clear,
            isCrossedOut: false
        )
    }
}

private enum Constants {
    static let borderWidthDefault: CGFloat = 1
    static let borderWidthSelected: CGFloat = 2
}
