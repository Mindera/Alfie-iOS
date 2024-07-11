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

        internal var color: Color {
            switch self {
                case .elevation1, .elevation2, .elevation3, .elevation4, .elevation5:
                    return Colors.primary.black.opacity(0.15)

                case .mediumFloat1:
                    return Colors.primary.mono900.opacity(0.1)
                case .mediumFloat2:
                    return Colors.primary.mono900.opacity(0.15)
                case .mediumFloat3:
                    return Colors.primary.mono900.opacity(0.2)
                case .mediumFloat4:
                    return Colors.primary.mono900.opacity(0.25)
                case .mediumFloat5:
                    return Colors.primary.mono900.opacity(0.3)

                case .softFloat1:
                    return Colors.primary.mono900.opacity(0.04)
                case .softFloat2:
                    return Colors.primary.mono900.opacity(0.06)
                case .softFloat3:
                    return Colors.primary.mono900.opacity(0.08)
                case .softFloat4:
                    return Colors.primary.mono900.opacity(0.10)
                case .softFloat5:
                    return Colors.primary.mono900.opacity(0.12)
            }
        }

        internal var radius: CGFloat {
            switch self {
                case .elevation1:
                    return 1.0
                case .elevation2:
                    return 2.0
                case .elevation3:
                    return 3.0
                case .elevation4:
                    return 4.0
                case .elevation5:
                    return 5.0

                case .mediumFloat1, .mediumFloat2, .mediumFloat3, .mediumFloat4, .mediumFloat5:
                    return 4.0

                case .softFloat1, .softFloat2, .softFloat3, .softFloat4, .softFloat5:
                    return 3.0
            }
        }

        internal var offset: CGPoint {
            switch self {
                case .elevation1:
                    return .init(x: 0.0, y: 1.0)
                case .elevation2:
                    return .init(x: 0.0, y: 2.0)
                case .elevation3:
                    return .init(x: 0.0, y: 3.0)
                case .elevation4:
                    return .init(x: 0.0, y: 4.0)
                case .elevation5:
                    return .init(x: 0.0, y: 5.0)

                case .mediumFloat1, .mediumFloat2, .mediumFloat3, .mediumFloat4, .mediumFloat5:
                    return .init(x: 0.0, y: 4.0)

                case .softFloat1, .softFloat2, .softFloat3, .softFloat4, .softFloat5:
                    return .init(x: 0.0, y: 0.0)
            }
        }
    }

    private let type: ShadowType

    public init(_ type: ShadowType) {
        self.type = type
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .shadow(color: type.color,
                    radius: type.radius,
                    x: type.offset.x,
                    y: type.offset.y)
    }
}

public extension View {
    /// Adds a shadow of the given type to a view
    func shadow(_ type: ShadowViewModifier.ShadowType) -> some View {
        self.modifier(ShadowViewModifier(type))
    }
}
