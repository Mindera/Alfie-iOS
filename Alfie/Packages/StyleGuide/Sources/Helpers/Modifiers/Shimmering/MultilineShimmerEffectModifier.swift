import SwiftUI

struct MultilineShimmerEffectModifier: ViewModifier {
    @State private var shouldShowShimmer = true
    @State private var linesPadding: [CGFloat]
    @Binding private var isLoading: Bool
    private let cornerRadius: CGFloat
    private let blurRadius: CGFloat
    private let lighterShimmerColor: Color
    private let darkerShimmerColor: Color
    private let lines: [Int]
    private let lineMaxRandomPadding: CGFloat
    private let font: UIFont
    private let lineSpacing: CGFloat
    private let disabledWhileShimmering: Bool
    private let animateOnStateTransition: Bool

    init(isLoading: Binding<Bool>,
         cornerRadius: CGFloat = 0,
         blurRadius: CGFloat = 0,
         customLighterShimmerColor: Color? = nil,
         customDarkerShimmerColor: Color? = nil,
         lines: Int,
         font: UIFont,
         lineMaxRandomPadding: CGFloat,
         lineSpacing: CGFloat,
         disabledWhileShimmering: Bool,
         animateOnStateTransition: Bool = true) {
        self._isLoading = isLoading
        self.shouldShowShimmer = isLoading.wrappedValue
        self.cornerRadius = cornerRadius
        self.blurRadius = blurRadius
        self.lighterShimmerColor = customLighterShimmerColor ?? Colors.primary.mono200
        self.darkerShimmerColor = customDarkerShimmerColor ?? Colors.primary.mono300
        self.lines = lines > 0 ? Array(0..<lines) : []
        self.font = font
        self.lineSpacing = lineSpacing
        self.linesPadding = lineMaxRandomPadding > 0 ? self.lines.map { _ in CGFloat.random(in: 0..<lineMaxRandomPadding) } : []
        self.lineMaxRandomPadding = lineMaxRandomPadding
        self.disabledWhileShimmering = disabledWhileShimmering
        self.animateOnStateTransition = animateOnStateTransition
     }

    func body(content: Content) -> some View {
        if shouldShowShimmer {
            content
                .frame(maxWidth: .infinity)
                .hidden()
                .disabled(disabledWhileShimmering)
                .overlay {
                    VStack(spacing: lineSpacing) {
                        ForEach(lines, id: \.self) { line in
                            Rectangle()
                                .shimmering(while: $isLoading)
                                .frame(height: font.lineHeight - lineSpacing)
                                .padding(.trailing, linesPadding.indices.contains(line) ? linesPadding[line] : 0)
                        }
                    }
                }
                .frame(height: CGFloat(lines.count) * font.lineHeight)
                .onChange(of: isLoading) { newValue in
                    withAnimation(animateOnStateTransition ? .easeIn(duration: 1) : .none) {
                        shouldShowShimmer = newValue
                    }
                }
                .transition(.opacity)
        } else {
            content
        }
    }
}

#Preview(body: {
    Text.build(ThemeProvider.shared.font.small.bold(Array(repeating: "Hello, world!", count: 24).joined(separator: " ")))
        .shimmeringMultiline(while: .constant(true), lines: 8, font: ThemeProvider.shared.font.small.bold)
        .padding(.horizontal, Spacing.space300)
})
