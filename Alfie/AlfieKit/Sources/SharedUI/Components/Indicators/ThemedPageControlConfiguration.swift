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
        color: Color = Primitives.Colours.neutrals200,
        selectedColor: Color = Primitives.Colours.neutrals600,
        animationDuration: CGFloat = 0.3,
        size: CGFloat = 10,
        spacing: CGFloat = 0,
        padding: CGFloat = Primitives.Spacing.spacing16
    ) {
        self.color = color
        self.selectedColor = selectedColor
        self.animationDuration = animationDuration
        self.size = size
        self.spacing = spacing
        self.padding = padding
    }
}

extension ThemedPageControlConfiguration {
    static let `default` = ThemedPageControlConfiguration(size: 8, spacing: Primitives.Spacing.spacing4)
}
