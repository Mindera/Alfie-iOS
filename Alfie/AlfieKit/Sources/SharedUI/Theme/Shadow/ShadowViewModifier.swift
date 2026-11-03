import SwiftUI

/// Defines a modifier that can apply a shadow from a given preset type to any view
public struct ShadowViewModifier: ViewModifier {
    public enum ShadowType {
        case elevation1
        case elevation2
        case elevation3
        case elevation4
        case elevation5

        case mediumFloat1
        case mediumFloat2
        case mediumFloat3
        case mediumFloat4
        case mediumFloat5

        case softFloat1
        case softFloat2
        case softFloat3
        case softFloat4
        case softFloat5

        internal var color: Color { Color.black.opacity(spec.opacity) }
        internal var radius: CGFloat { spec.radius }
        internal var offset: CGPoint { .init(x: 0, y: spec.y) }

        // swiftlint:disable vertical_whitespace_between_cases
        private var spec: (opacity: Double, radius: CGFloat, y: CGFloat) {
            switch self {
            case .elevation1:
                (0.15, 1, 1)
            case .elevation2:
                (0.15, 2, 2)
            case .elevation3:
                (0.15, 3, 3)
            case .elevation4:
                (0.15, 4, 4)
            case .elevation5:
                (0.15, 5, 5)
            case .mediumFloat1:
                (0.1, 4, 4)
            case .mediumFloat2:
                (0.15, 4, 4)
            case .mediumFloat3:
                (0.2, 4, 4)
            case .mediumFloat4:
                (0.25, 4, 4)
            case .mediumFloat5:
                (0.3, 4, 4)
            case .softFloat1:
                (0.04, 3, 0)
            case .softFloat2:
                (0.06, 3, 0)
            case .softFloat3:
                (0.08, 3, 0)
            case .softFloat4:
                (0.1, 3, 0)
            case .softFloat5:
                (0.12, 3, 0)
            }
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private let type: ShadowType

    public init(_ type: ShadowType) {
        self.type = type
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .shadow(color: type.color, radius: type.radius, x: type.offset.x, y: type.offset.y)
    }
}

public extension View {
    /// Adds a shadow of the given type to a view
    func shadow(_ type: ShadowViewModifier.ShadowType) -> some View {
        self.modifier(ShadowViewModifier(type))
    }
}
