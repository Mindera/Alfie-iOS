import SwiftUI

/// Adopt this protocol if you want to customize certain properties on your view when shimmering is applied. For example, by default, shimmering's cornerRadius is 0, but if your view has a different value, you might want to replicate it here. __All properties are optional.__
/// ```swift
/// extension MyCustomView: CustomShimmerable {
///     var cornerRadius: CGFloat { 16 }
/// }
///
/// extension MyCustomView2: CustomShimmerable {
///     var cornerRadius: CGFloat { 8 }
///     var customLighterShimmerColor: Color? { .gray }
///     var customDarkerShimmerColor: Color? { .black }
/// }
/// ```
public protocol CustomShimmerable: View {
    var cornerRadius: CGFloat { get }
    var customLighterShimmerColor: Color? { get }
    var customDarkerShimmerColor: Color? { get }
}

extension CustomShimmerable {
    public var cornerRadius: CGFloat { 0 }
    public var customLighterShimmerColor: Color? { nil }
    public var customDarkerShimmerColor: Color? { nil }
}

// MARK: Overloads:
extension CustomShimmerable {
    public func shimmering(while loading: Binding<Bool>, disabledWhileShimmering: Bool = true) -> some View {
        self.modifier(
            ShimmerEffectModifier(
                isLoading: loading,
                cornerRadius: cornerRadius,
                customLighterShimmerColor: customLighterShimmerColor,
                customDarkerShimmerColor: customDarkerShimmerColor,
                disabledWhileShimmering: disabledWhileShimmering
            )
        )
    }
}

extension CustomShimmerable {
    public func shimmeringMultiline(
        while loading: Binding<Bool>,
        lines: Int = 5,
        lineMaxRandomPadding: CGFloat = 0,
        lineSpacing: CGFloat? = nil,
        font: UIFont,
        disabledWhileShimmering: Bool = true
    ) -> some View {
        self.modifier(
            MultilineShimmerEffectModifier(
                isLoading: loading,
                cornerRadius: cornerRadius,
                customLighterShimmerColor: customLighterShimmerColor,
                customDarkerShimmerColor: customDarkerShimmerColor,
                lines: lines,
                font: font,
                lineMaxRandomPadding: lineMaxRandomPadding,
                lineSpacing: lineSpacing ?? font.lineHeight / 5,
                disabledWhileShimmering: disabledWhileShimmering
            )
        )
    }
}
