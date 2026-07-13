import SwiftUI

/// Renders an ``Icon`` at a token-driven size with a template tint, replacing the
/// hand-rolled `renderingMode(.template).resizable().scaledToFit().frame(...).foregroundStyle(...)`
/// chain repeated across components. Size comes from the generated `Sizing.iconsIcon*` tokens.
public struct ThemedIcon: View {
    public enum Size {
        case small
        case medium
        case large
        case xlarge

        var dimension: CGFloat {
            switch self {
            case .small:
                return Sizing.iconsIconSmall
            case .medium:
                return Sizing.iconsIconMedium
            case .large:
                return Sizing.iconsIconLarge
            case .xlarge:
                return Sizing.iconsIconXlarge
            }
        }
    }

    private let icon: Icon
    private let size: Size
    private let tint: Color

    public init(_ icon: Icon, size: Size = .medium, tint: Color) {
        self.icon = icon
        self.size = size
        self.tint = tint
    }

    public var body: some View {
        icon.image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size.dimension, height: size.dimension)
            .foregroundStyle(tint)
    }
}
