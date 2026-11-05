import SwiftUI

public struct ThemedPageControlConfiguration {
    public let color: Color
    public let selectedColor: Color
    public let animationDuration: CGFloat
    public let size: CGFloat
    public let spacing: CGFloat
    /// Inset around the whole control. Defaults to 16pt, preserving the previously hardcoded
    /// `.padding()`; call sites that position the control themselves — an overlay, say — pass `0`.
    public let padding: CGFloat

    public init(
        color: Color = DesignSystem.shared.color.borderSoft,
        selectedColor: Color = DesignSystem.shared.color.contentContentSecondary,
        animationDuration: CGFloat = 0.3,
        size: CGFloat = 10,
        spacing: CGFloat = 0,
        padding: CGFloat = DesignSystem.shared.sizing.spacingSpacingMd
    ) {
        self.color = color
        self.selectedColor = selectedColor
        self.animationDuration = animationDuration
        self.size = size
        self.spacing = spacing
        self.padding = padding
    }
}

extension ThemedPageControlConfiguration: ThemeReading {
    static let `default` = ThemedPageControlConfiguration(
        size: 8,
        spacing: theme.sizing.spacingSpacing2xs
    )
}
