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
    private let accessibilityLabel: String?

    /// - Parameter accessibilityLabel: a localized label for a semantic icon (e.g. an icon-only
    ///   button). Leave `nil` for decorative icons — bundled assets otherwise expose their raw
    ///   asset name to VoiceOver, so decorative icons are hidden from assistive tech.
    public init(_ icon: Icon, size: Size = .medium, tint: Color, accessibilityLabel: String? = nil) {
        self.icon = icon
        self.size = size
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        icon.image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size.dimension, height: size.dimension)
            .foregroundStyle(tint)
            .accessibilityLabelOrHidden(accessibilityLabel)
    }
}

private extension View {
    @ViewBuilder
    func accessibilityLabelOrHidden(_ label: String?) -> some View {
        if let label {
            accessibilityLabel(Text(label))
        } else {
            accessibilityHidden(true)
        }
    }
}
