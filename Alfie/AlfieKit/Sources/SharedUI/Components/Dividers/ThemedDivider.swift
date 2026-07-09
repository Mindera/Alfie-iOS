import SwiftUI

// MARK: - ThemedDividerConfiguration

public struct ThemedDividerConfiguration {
    public enum ThemedDividerOrientation {
        case horizontal
        case vertical
    }

    let orientation: ThemedDividerOrientation
    let thickness: CGFloat
    let color: Color

    public init(orientation: ThemedDividerOrientation, thickness: CGFloat, color: Color) {
        self.orientation = orientation
        self.thickness = thickness
        self.color = color
    }
}

// MARK: - ThemedDivider

public struct ThemedDivider: View {
    private enum Constants {
        static let thinThickness = 1.0
        static let thickThickness = 2.0
    }

    // Computed (not stored) so the divider colour is re-read from the active theme palette on every
    // access. A stored static would snapshot `Primitives.Colours.neutrals100` once at first access and
    // keep that value across theme switches (the soft-reboot keeps the process — and its statics — alive).
    public static var horizontalThin: ThemedDivider {
        ThemedDivider(
            configuration: .init(
                orientation: .horizontal,
                thickness: Constants.thinThickness,
                color: Primitives.Colours.neutrals100
            )
        )
    }
    public static var verticalThin: ThemedDivider {
        ThemedDivider(
            configuration: .init(orientation: .vertical, thickness: Constants.thinThickness, color: Primitives.Colours.neutrals100)
        )
    }
    public static var horizontalThick: ThemedDivider {
        ThemedDivider(
            configuration: .init(
                orientation: .horizontal,
                thickness: Constants.thickThickness,
                color: Primitives.Colours.neutrals100
            )
        )
    }
    public static var verticalThick: ThemedDivider {
        ThemedDivider(
            configuration: .init(orientation: .vertical, thickness: Constants.thickThickness, color: Primitives.Colours.neutrals100)
        )
    }
    private let configuration: ThemedDividerConfiguration

    public init(configuration: ThemedDividerConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        Rectangle()
            .fill(configuration.color)
            .frame(
                maxWidth: configuration.orientation == .horizontal ? .infinity : configuration.thickness,
                maxHeight: configuration.orientation == .vertical ? .infinity : configuration.thickness
            )
    }
}

#Preview {
    VStack {
        HStack {
            ThemedDivider.horizontalThin
        }
        .frame(height: 50)
        Spacer()
        HStack {
            ThemedDivider.horizontalThick
        }
        .frame(height: 50)
        Spacer()
        HStack {
            Spacer()
            ThemedDivider.verticalThin
            Spacer()
            ThemedDivider.verticalThick
            Spacer()
        }
        .frame(height: 50)
        Spacer()
        HStack {
            ThemedDivider(
                configuration: .init(orientation: .horizontal, thickness: 5.0, color: Primitives.Colours.semanticError400)
            )
            Spacer()
            ThemedDivider(
                configuration: .init(orientation: .vertical, thickness: 5.0, color: Primitives.Colours.semanticError400)
            )
        }
        .frame(height: 50)
    }
    .padding()
}
