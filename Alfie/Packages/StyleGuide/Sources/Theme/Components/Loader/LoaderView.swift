import SwiftUI

public struct LoaderView: View {
    public enum CircleDiameter {
        case defaultSmall
        case custom(CGFloat)
    }

    public enum CircleStyle {
        case dark
        case light

        var color: Color {
            switch self {
                case .dark:
                    return Colors.primary.black
                case .light:
                    return Colors.primary.white
            }
        }
    }

    private enum Constants {
        static let smallCircleDiameter: CGFloat = 8
		static let circleSpacing: CGFloat = Spacing.space100
		static let circlesToLabelSpacing: CGFloat = Spacing.space150
        static let numberOfCircles = 3
        static let animationTime: Double = 0.5
    }

    private let circleDiameter: CGFloat
    private let labelHidden: Bool
    private let labelTitle: String
    private let style: CircleStyle

    public init(circleDiameter: CircleDiameter, style: CircleStyle = .dark, labelHidden: Bool = true, labelTitle: String = "Loading") {
        switch circleDiameter {
            case .defaultSmall:
                self.circleDiameter = Constants.smallCircleDiameter
            case let .custom(cgSize):
                self.circleDiameter = cgSize
        }

        self.labelHidden = labelHidden
        self.labelTitle = labelTitle
        self.style = style
    }

    public var body: some View {
        VStack(spacing: Constants.circlesToLabelSpacing) {
            HStack(spacing: Constants.circleSpacing) {
                ForEach(0 ..< Constants.numberOfCircles, id: \.self) { index in
                    AnimatedCircle(style: style, animationTime: Constants.animationTime,
                                   delayBeforeFirstAnimation: Constants.animationTime / Double(Constants.numberOfCircles) * Double(index))
                        .frame(width: circleDiameter, height: circleDiameter)
                }
            }

            if !labelHidden {
                Text.build(theme.font.paragraph.normal(labelTitle))
                    .foregroundStyle(Colors.primary.black)
            }
        }
    }
}

private struct AnimatedCircle: View {
    @State private var isAppearing = false
    private let animationTime: Double
    private let style: LoaderView.CircleStyle
    private let delayBeforeFirstAnimation: Double
    private let timer: Timer.TimerPublisher

    private enum Constants {
        static let minScale: CGFloat = 0.75
        static let minOpacity: CGFloat = 0.2
    }

    init(style: LoaderView.CircleStyle, animationTime: Double, delayBeforeFirstAnimation: Double) {
        self.style = style
        self.animationTime = animationTime
        self.delayBeforeFirstAnimation = delayBeforeFirstAnimation
        timer = Timer.publish(every: animationTime, on: .main, in: .default)
        _ = timer.connect()
    }

    var body: some View {
        Circle()
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: animationTime).delay(delayBeforeFirstAnimation)) {
                    isAppearing.toggle()
                }
            }
            .foregroundColor(style.color)
            .opacity(isAppearing ? 1.0 : Constants.minOpacity)
            .scaleEffect(isAppearing ? 1.0 : Constants.minScale)
    }
}

#Preview {
    VStack(spacing: 48) {
        LoaderView(circleDiameter: .defaultSmall, labelHidden: false)

        LoaderView(circleDiameter: .custom(30), labelHidden: false)
    }
}
