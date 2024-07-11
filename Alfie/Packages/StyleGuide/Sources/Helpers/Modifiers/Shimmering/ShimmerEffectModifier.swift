import SwiftUI

struct ShimmerEffectModifier: ViewModifier {
    @State private var startPoint = UnitPoint(x: -1.5, y: -0.3)
    @State private var endPoint = UnitPoint(x: 0, y: 0.3)
    @State private var shouldShowShimmer = true
    @Binding private var isLoading: Bool
    private let cornerRadius: CGFloat
    private let blurRadius: CGFloat
    private let lighterShimmerColor: Color
    private let darkerShimmerColor: Color
    private let disabledWhileShimmering: Bool
    private let animateOnStateTransition: Bool

    init(isLoading: Binding<Bool>,
         cornerRadius: CGFloat = 0,
         blurRadius: CGFloat = 0,
         customLighterShimmerColor: Color? = nil,
         customDarkerShimmerColor: Color? = nil,
         disabledWhileShimmering: Bool,
         animateOnStateTransition: Bool = true) {
        self._isLoading = isLoading
        self.shouldShowShimmer = isLoading.wrappedValue
        self.cornerRadius = cornerRadius
        self.blurRadius = blurRadius
        self.lighterShimmerColor = customLighterShimmerColor ?? Colors.primary.mono200
        self.darkerShimmerColor = customDarkerShimmerColor ?? Colors.primary.mono300
        self.disabledWhileShimmering = disabledWhileShimmering
        self.animateOnStateTransition = animateOnStateTransition
     }

    func body(content: Content) -> some View {
        if shouldShowShimmer {
            content
                .hidden()
                .disabled(disabledWhileShimmering)
                .overlay {
                    Rectangle()
                        .fill(
                            .linearGradient(
                                colors: [
                                    lighterShimmerColor,
                                    darkerShimmerColor,
                                    lighterShimmerColor,
                                ],
                                startPoint: startPoint,
                                endPoint: endPoint
                            )
                        )
                        .cornerRadius(cornerRadius)
                        .blur(radius: blurRadius)
                }
                .task {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        startPoint = .init(x: 1.5, y: -0.3)
                        endPoint = .init(x: 3, y: 0.5)
                    }
                }
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
    Rectangle()
        .shimmering(while: .constant(true))
})
