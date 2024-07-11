import SwiftUI

public struct ThemedPageControlConfiguration {
    let color: Color
    let selectedColor: Color
    let animationDuration: CGFloat
    let size: CGFloat
    let spacing: CGFloat

    public init(color: Color = Colors.primary.mono200,
                selectedColor: Color = Colors.primary.mono600,
                animationDuration: CGFloat = 0.3,
                size: CGFloat = 10,
                spacing: CGFloat = 0) {
        self.color = color
        self.selectedColor = selectedColor
        self.animationDuration = animationDuration
        self.size = size
        self.spacing = spacing
    }
}

extension ThemedPageControlConfiguration {
    static let `default` = ThemedPageControlConfiguration(size: 8, spacing: Spacing.space050)
}
