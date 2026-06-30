import SwiftUI

// MARK: - ErrorView

public struct ErrorView: View {
    // MARK: Inner types

    public struct ButtonConfiguration: Identifiable {
        let cta: String
        let action: () -> Void

        public var id: String {
            cta
        }

        public init(cta: String, action: @escaping () -> Void) {
            self.cta = cta
            self.action = action
        }
    }

    public enum Constants {
        public static let iconSize: CGFloat = 48
    }

    // MARK: Properties

    private let spacing: CGFloat
    private let icon: Image?
    private let iconColor: Color
    private let iconSize: CGFloat
    private let title: AttributedString?
    private let titleColor: Color
    private let message: AttributedString?
    private let messageColor: Color
    private let buttons: [ButtonConfiguration]

    // MARK: Lifecycle

    public init(
        spacing: CGFloat = Spacing.space200,
        icon: Image? = Icon.warning.image,
        iconColor: Color = Primitives.Colours.neutrals900,
        iconSize: CGFloat = Constants.iconSize,
        title: AttributedString? = nil,
        titleColor: Color = Primitives.Colours.neutrals900,
        message: AttributedString? = nil,
        messageColor: Color = Primitives.Colours.neutrals900,
        buttons: [ButtonConfiguration] = []
    ) {
        self.spacing = spacing
        self.icon = icon
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.title = title
        self.titleColor = titleColor
        self.message = message
        self.messageColor = messageColor
        self.buttons = buttons
    }

    public init(
        spacing: CGFloat = Spacing.space200,
        icon: Image? = Icon.warning.image,
        iconColor: Color = Primitives.Colours.neutrals900,
        iconSize: CGFloat = Constants.iconSize,
        title: String? = nil,
        titleColor: Color = Primitives.Colours.neutrals900,
        message: String? = nil,
        messageColor: Color = Primitives.Colours.neutrals900,
        buttons: [ButtonConfiguration] = []
    ) {
        self.init(
            spacing: spacing,
            icon: icon,
            iconColor: iconColor,
            iconSize: iconSize,
            title: title.map { ThemeProvider.shared.font.body.medium($0) },
            titleColor: titleColor,
            message: message.map { ThemeProvider.shared.font.body.small($0) },
            messageColor: messageColor,
            buttons: buttons
        )
    }

    public var body: some View {
        VStack(spacing: spacing) {
            Spacer()

            if let icon {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(iconColor)
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }

            if let title {
                Text.build(title)
                    .foregroundStyle(Primitives.Colours.neutrals900)
            }

            if let message {
                Text.build(message)
                    .foregroundStyle(Primitives.Colours.neutrals900)
            }

            VStack(spacing: Spacing.space100) {
                ForEach(buttons) {
                    ThemedButton(text: $0.cta, isFullWidth: true, action: $0.action)
                }
            }

            Spacer()
        }
    }
}
