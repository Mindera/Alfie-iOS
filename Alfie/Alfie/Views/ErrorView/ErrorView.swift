import StyleGuide
import SwiftUI

// MARK: - Constants

private enum Constants {
    static let iconSize: CGFloat = 48
}

// MARK: - ErrorView

struct ErrorView: View {
    // MARK: Properties

    private let spacing: CGFloat
    private let icon: Image?
    private let iconColor: Color
    private let iconSize: CGFloat
    private let title: AttributedString?
    private let titleColor: Color
    private let message: AttributedString?
    private let messageColor: Color
    private let buttonsConfiguration: [ErrorButtonConfiguration]

    // MARK: Lifecycle

    init(
        spacing: CGFloat = Spacing.space200,
        icon: Image? = Icon.warning.image,
        iconColor: Color = Colors.primary.black,
        iconSize: CGFloat = Constants.iconSize,
        title: AttributedString? = nil,
        titleColor: Color = Colors.primary.black,
        message: AttributedString? = nil,
        messageColor: Color = Colors.primary.black,
        buttonsConfiguration: [ErrorButtonConfiguration] = []
    ) {
        self.spacing = spacing
        self.icon = icon
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.title = title
        self.titleColor = titleColor
        self.message = message
        self.messageColor = messageColor
        self.buttonsConfiguration = buttonsConfiguration
    }

    init(
        spacing: CGFloat = Spacing.space200,
        icon: Image? = Icon.warning.image,
        iconColor: Color = Colors.primary.black,
        iconSize: CGFloat = Constants.iconSize,
        title: String? = nil,
        titleColor: Color = Colors.primary.black,
        message: String? = nil,
        messageColor: Color = Colors.primary.black,
        buttonsConfiguration: [ErrorButtonConfiguration] = []
    ) {
        self.init(
            spacing: spacing,
            icon: icon,
            iconColor: iconColor,
            iconSize: iconSize,
            title: title.flatMap(ThemeProvider.shared.font.paragraph.bold),
            titleColor: titleColor,
            message: message.flatMap(ThemeProvider.shared.font.small.normal),
            messageColor: messageColor,
            buttonsConfiguration: buttonsConfiguration
        )
    }

    var body: some View {
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
                    .foregroundStyle(Colors.primary.black)
            }

            if let message {
                Text.build(message)
                    .foregroundStyle(Colors.primary.black)
            }

            VStack(spacing: Spacing.space100) {
                ForEach(buttonsConfiguration) { configuration in
                    ThemedButton(
                        text: configuration.text,
                        isFullWidth: true,
                        action: configuration.action
                    )
                }
            }

            Spacer()
        }
    }
}
