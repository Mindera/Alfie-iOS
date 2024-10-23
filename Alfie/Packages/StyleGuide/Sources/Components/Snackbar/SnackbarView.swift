import SwiftUI

/// Defines a configuration for displaying a Snackbar.
public struct SnackbarViewConfiguration: Equatable {
    public enum SnackbarViewType {
        case info
        case success
        case error
    }

    public let type: SnackbarViewType
    public let text: String
    public let showCloseButton: Bool
    public let icon: Image?
    public let actionButtonLabel: String?
    public let showFromTop: Bool
    public let autoDismissTime: TimeInterval?
    public let lineLimit: Int

    public let onActionTap: (() -> Void)?
    public let onDismiss: (() -> Void)?

    /// Creates a configuration for displaying a Snackbar.
    /// - Parameters:
    ///   - type: the type of snackbar to display
    ///   - text: a message to show on the snackbar (can be truncated if line limit is exceeded)
    ///   - showCloseButton: should a close button be shown
    ///   - icon: optional icon to show (default is a checkmark)
    ///   - actionButtonLabel: an optional text to show as an action button (pass nil to hide the button)
    ///   - showFromTop: controls if the snackbar should be shown from the top instead of from the bottom as default
    ///   - autoDismissTime: an optional to control the time after which the snackbar is automatically dismissed (default is 5s, pass 0 or nil to avoid automatic dismissal)
    ///   - lineLimit: the line limit for the text displayed (default is 2)
    ///   - onActionTap: an option closure to be called when the user taps the action button (the snackbar won't dismiss automatically)
    ///   - onDismiss: an optional closure to be called when the snackbar is dismissed, either automatically of by the user
    public init(
        type: SnackbarViewType = .info,
        text: String,
        showCloseButton: Bool = false,
        icon: Image? = Icon.checkmark.image,
        actionButtonLabel: String? = nil,
        showFromTop: Bool = false,
        autoDismissTime: TimeInterval? = 5,
        lineLimit: Int = 2,
        onActionTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.type = type
        self.text = text
        self.showCloseButton = showCloseButton
        self.icon = icon
        self.actionButtonLabel = actionButtonLabel
        self.showFromTop = showFromTop
        self.autoDismissTime = autoDismissTime
        self.lineLimit = lineLimit

        self.onActionTap = onActionTap
        self.onDismiss = onDismiss
    }

    public static func == (lhs: SnackbarViewConfiguration, rhs: SnackbarViewConfiguration) -> Bool {
        lhs.type == rhs.type &&
        lhs.text == rhs.text &&
        lhs.showCloseButton == rhs.showCloseButton &&
        lhs.icon == rhs.icon &&
        lhs.actionButtonLabel == rhs.actionButtonLabel &&
        lhs.showFromTop == rhs.showFromTop &&
        lhs.autoDismissTime == rhs.autoDismissTime &&
        lhs.lineLimit == rhs.lineLimit
    }
}

public struct SnackbarView: View {
    private enum Constants {
        static let iconWidth = 24.0
        static let iconHeight = 24.0
        static let minHeight = 48.0
    }

    private let configuration: SnackbarViewConfiguration
    private let onCloseTap: (() -> Void)?

    public init(configuration: SnackbarViewConfiguration, onCloseTap: (() -> Void)? = nil) {
        self.configuration = configuration
        self.onCloseTap = onCloseTap
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .cornerRadius(CornerRadius.s)
            HStack(spacing: Spacing.space100) {
                if let icon = configuration.icon {
                    icon
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                        .foregroundStyle(foregroundColor)
                }
                Text.build(theme.font.paragraph.normal(configuration.text))
                    .foregroundColor(foregroundColor)
                    .padding(Spacing.space200)
                    .lineLimit(configuration.lineLimit)
                Spacer()
                if let actionButtonLabel = configuration.actionButtonLabel {
                    Button(action: {
                        configuration.onActionTap?()
                    }, label: {
                        Text.build(theme.font.paragraph.bold(actionButtonLabel))
                            .foregroundColor(foregroundColor)
                            .padding(Spacing.space200)
                    })
                }
                if configuration.showCloseButton {
                    Button(action: {
                        onCloseTap?()
                    }, label: {
                        Icon.close.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                            .foregroundStyle(foregroundColor)
                    })
                }
            }
            .padding(.horizontal, Spacing.space200)
            .frame(minHeight: Constants.minHeight)
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
    }

    private var backgroundColor: Color {
        switch configuration.type {
        case .info:
            return Colors.primary.black

        case .success:
            return Colors.secondary.green100

        case .error:
            return Colors.secondary.red100
        }
    }

    private var foregroundColor: Color {
        switch configuration.type {
        case .info:
            return Colors.primary.white

        case .success:
            return Colors.secondary.green800

        case .error:
            return Colors.secondary.red800
        }
    }
}

#Preview {
    VStack {
        SnackbarView(
            configuration: SnackbarViewConfiguration(
                text: "Text message",
                showCloseButton: true,
                actionButtonLabel: "Action"
            )
        )

        SnackbarView(
            configuration: SnackbarViewConfiguration(
                text: "Text message with multiple lines",
                showCloseButton: true,
                actionButtonLabel: "Action"
            )
        )

        SnackbarView(configuration: SnackbarViewConfiguration(text: "Text message", actionButtonLabel: "Action"))

        SnackbarView(configuration: SnackbarViewConfiguration(text: "Text message", actionButtonLabel: "Action"))

        SnackbarView(configuration: SnackbarViewConfiguration(text: "Text message without accessories"))

        SnackbarView(
            configuration: SnackbarViewConfiguration(text: "Text message with multiple lines without accessories")
        )

        SnackbarView(
            configuration: SnackbarViewConfiguration(type: .success, text: "Success message", showCloseButton: true)
        )

        SnackbarView(
            configuration: SnackbarViewConfiguration(
                type: .success,
                text: "Success message",
                showCloseButton: true,
                actionButtonLabel: "Action"
            )
        )

        SnackbarView(
            configuration: SnackbarViewConfiguration(
                type: .error,
                text: "Error message",
                showCloseButton: true,
                actionButtonLabel: "Action"
            )
        )
    }
    .padding(.horizontal, Spacing.space100)
}
