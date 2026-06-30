import SharedUI
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
            // swiftlint:disable vertical_whitespace_between_cases
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
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }

    @State private var motionType: MotionTypes = .emphasized
    @State private var animationRotationDegrees: Double = 0
    @State private var showRectangle = false

    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing20) {
            DemoHelper.demoSectionHeader(title: "Motion")

            HStack {
                Text.build(theme.font.body.small("Type"))
                Spacer()
                Menu {
                    Picker(selection: $motionType) {
                        ForEach(MotionTypes.allCases, id: \.self) { motionType in
                            Text(motionType.rawValue)
                        }
                    } label: {
                    }
                } label: {
                    Text.build(theme.font.body.small(motionType.rawValue))
                        .tint(Primitives.Colours.neutrals400)
                }
            }

            ThemedButton(text: "Preview") {
                withAnimation(motionType.correspondingAnimation) {
                    showRectangle.toggle()
                }
            }

            if showRectangle {
                Spacer()
            }

            HStack {
                if showRectangle {
                    Circle()
                        .cornerRadius(10)
                        .transition(circleTransition(from: .leading))
                        .foregroundStyle(Primitives.Colours.neutrals300)

                    Circle()
                        .cornerRadius(10)
                        .transition(circleTransition(from: .bottom))
                        .foregroundStyle(Primitives.Colours.neutrals400)

                    Circle()
                        .cornerRadius(10)
                        .transition(circleTransition(from: .trailing))
                        .foregroundStyle(Primitives.Colours.neutrals500)
                }
            }
            .padding(Primitives.Spacing.spacing16)
            .frame(maxWidth: showRectangle ? .infinity : 0, maxHeight: showRectangle ? 300 : 0)
            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
        .edgesIgnoringSafeArea(.bottom)
    }

    func circleTransition(from edge: Edge) -> AnyTransition {
        .move(edge: edge).combined(with: .scale(scale: 4)).combined(with: .opacity)
    }
}

#Preview {
    MotionDemoView()
}
