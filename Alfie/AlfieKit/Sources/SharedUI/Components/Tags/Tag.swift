import SwiftUI

public struct TagConfiguration {
    public let label: String
    public let showCloseButton: Bool
    public let icon: Image?
    public let color: Color

    public let onCloseTap: (() -> Void)?

    public init(
        label: String,
        showCloseButton: Bool = false,
        icon: Image? = nil,
        // swiftlint:disable:next no_primitive_tokens - design review #186: no tag accent token
        color: Color = Primitives.Colours.neutrals700,
        onCloseTap: (() -> Void)? = nil
    ) {
        self.label = label
        self.showCloseButton = showCloseButton
        self.icon = icon
        self.color = color
        self.onCloseTap = onCloseTap
    }
}

public struct Tag: View {
    private enum Constants {
        static let height = 32.0
        static let strokeWidth = 2.0
        static let cornerRadius = 2.0
        static let iconWidth = 16.0
        static let iconHeight = 16.0
        static let closeWidth = 12.0
        static let closeHeight = 12.0
    }

    private let configuration: TagConfiguration

    public init(configuration: TagConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        HStack(spacing: theme.sizing.spacingSpacingNone) {
            Rectangle()
                .fill(configuration.color)
                .frame(width: Constants.strokeWidth)
            HStack(spacing: theme.sizing.spacingSpacingXs) {
                if let icon = configuration.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                }
                Text.build(theme.font.body.medium(configuration.label))
                if configuration.showCloseButton {
                    Button(action: {
                        configuration.onCloseTap?()
                    }, label: {
                        Icon.close.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.closeWidth, height: Constants.closeHeight)
                            .foregroundStyle(theme.color.contentContentPrimary)
                    })
                    .accessibilityLabel(Text(L10n.Accessibility.close))
                }
            }
            .padding(.horizontal, theme.sizing.spacingSpacingSm)
        }
        .background(theme.color.surfaceForegroundPrimary)
        .cornerRadius(Constants.cornerRadius)
        .frame(height: Constants.height)
        // swiftlint:disable:next no_primitive_tokens - design review #186: no shadow token
        .shadow(color: Primitives.Colours.neutrals900.opacity(0.1), radius: 4, x: 2, y: 2)
    }
}

#Preview {
    VStack(spacing: 30) {
        Tag(configuration: .init(label: "Label"))
        Tag(configuration: .init(label: "Label", showCloseButton: true))
        Tag(configuration: .init(label: "Label", showCloseButton: false, icon: Icon.info.image))
        Tag(configuration: .init(label: "Label", showCloseButton: true, icon: Icon.info.image))
        Spacer()
    }
    .padding()
}
