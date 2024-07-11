import SwiftUI

struct MotionDemoView: View {
    enum MotionTypes: String, CaseIterable {
        case standard = "Standard"
        case standardAccelerate = "Standard Accelerate"
        case standardDecelerate = "Standard Decelerate"
        case emphasized = "Emphasized"
        case emphasizedAccelerate = "Emphasized Accelerate"
        case emphasizedDecelerate = "Emphasized Decelerate"

        var correspondingAnimation: Animation {
            switch self {
                case .standard:
                    return .standard
                case .standardAccelerate:
                    return .standardAccelerate
                case .standardDecelerate:
                    return .standardDecelerate
                case .emphasized:
                    return .emphasized
                case .emphasizedAccelerate:
                    return .emphasizedAccelerate
                case .emphasizedDecelerate:
                    return .emphasizedDecelerate
            }
        }
    }

    @State private var motionType: MotionTypes = .emphasized
    @State private var animationRotationDegrees: Double = 0
    @State private var showRectangle = false

    var body: some View {
        VStack(spacing: Spacing.space250) {
            DemoHelper.demoSectionHeader(title: "Motion")

            HStack {
                Text.build(theme.font.small.bold("Type"))
                Spacer()
                Menu {
                    Picker(selection: $motionType) {
                        ForEach(MotionTypes.allCases, id: \.self) { motionType in
                            Text(motionType.rawValue)
                        }
                    } label: {
                    }
                } label: {
                    Text.build(theme.font.small.normal(motionType.rawValue))
                        .tint(Colors.secondary.blue500)
                }
            }

            ThemedButton(text: "Preview", action: {
                withAnimation(motionType.correspondingAnimation) {
                    showRectangle.toggle()
                }
            })

            if showRectangle {
                Spacer()
            }

            HStack {
                if showRectangle {
                    Circle()
                        .cornerRadius(10)
                        .transition(circleTransition(from: .leading))
                        .foregroundColor(Colors.secondary.blue300)

                    Circle()
                        .cornerRadius(10)
                        .transition(circleTransition(from: .bottom))
                        .foregroundColor(Colors.secondary.blue500)

                    Circle()
                        .cornerRadius(10)
                        .transition(circleTransition(from: .trailing))
                        .foregroundColor(Colors.secondary.blue700)
                }
            }
            .padding(Spacing.space200)
            .frame(maxWidth: showRectangle ? .infinity : 0,
                   maxHeight: showRectangle ? 300 : 0)
            Spacer()
        }
        .padding(.horizontal, Spacing.space200)
        .edgesIgnoringSafeArea(.bottom)
    }

    func circleTransition(from edge: Edge) -> AnyTransition {
        .move(edge: edge).combined(with: .scale(scale: 4)).combined(with: .opacity)
    }
}

#Preview {
    MotionDemoView()
}
