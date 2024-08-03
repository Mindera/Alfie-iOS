import SwiftUI

extension View {
    public func shimmering(
        while loading: Binding<Bool>,
        disabledWhileShimmering: Bool = true,
        animateOnStateTransition: Bool = true,
        cornerRadius: CGFloat = 0
    ) -> some View {
        self.modifier(
            ShimmerEffectModifier(
                isLoading: loading,
                cornerRadius: cornerRadius,
                disabledWhileShimmering: disabledWhileShimmering,
                animateOnStateTransition: animateOnStateTransition
            )
        )
    }
}

extension View {
    public func shimmeringMultiline(
        while loading: Binding<Bool>,
        lines: Int = 5,
        lineMaxRandomPadding: CGFloat = 0,
        lineSpacing: CGFloat? = nil,
        font: UIFont,
        disabledWhileShimmering: Bool = true,
        animateOnStateTransition: Bool = true
    ) -> some View {
        self.modifier(
            MultilineShimmerEffectModifier(
                isLoading: loading,
                lines: lines,
                font: font,
                lineMaxRandomPadding: lineMaxRandomPadding,
                lineSpacing: lineSpacing ?? font.lineHeight / 5,
                disabledWhileShimmering: disabledWhileShimmering,
                animateOnStateTransition: animateOnStateTransition
            )
        )
    }
}
