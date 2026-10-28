import SwiftUI

// MARK: - ErrorView

public struct ErrorView: View {
    // MARK: Inner types

    public struct ButtonConfiguration: Identifiable {
        let cta: String
        let accessibilityId: String?
        let action: () -> Void

        public var id: String {
            cta
        }

        public init(cta: String, accessibilityId: String? = nil, action: @escaping () -> Void) {
            self.cta = cta
            self.accessibilityId = accessibilityId
            self.action = action
        }
    }

    public enum Constants {
        public static let iconSize: CGFloat = 48
    }

    // MARK: Properties

    private let spacing: CGFloat
    private let icon: Image?
    private let iconSize: CGFloat
    private let title: AttributedString?
    private let message: AttributedString?
    private let buttons: [ButtonConfiguration]

    // MARK: Lifecycle

    public init(
        spacing: CGFloat = DesignSystem.shared.sizing.spacingSpacingMd,
        icon: Image? = Icon.warning.image,
        iconSize: CGFloat = Constants.iconSize,
        title: AttributedString? = nil,
        message: AttributedString? = nil,
        buttons: [ButtonConfiguration] = []
    ) {
        self.spacing = spacing
        self.icon = icon
        self.iconSize = iconSize
        self.title = title
        self.message = message
        self.buttons = buttons
    }

    public init(
        spacing: CGFloat = DesignSystem.shared.sizing.spacingSpacingMd,
        icon: Image? = Icon.warning.image,
        iconSize: CGFloat = Constants.iconSize,
        title: String? = nil,
        message: String? = nil,
        buttons: [ButtonConfiguration] = []
    ) {
        self.init(
            spacing: spacing,
            icon: icon,
            iconSize: iconSize,
            title: title.map { DesignSystem.shared.font.body.medium($0) },
            message: message.map { DesignSystem.shared.font.body.small($0) },
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
                    .foregroundStyle(theme.color.contentContentPrimary)
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }

            if let title {
                Text.build(title)
                    .foregroundStyle(theme.color.contentContentPrimary)
            }

            if let message {
                Text.build(message)
                    .foregroundStyle(theme.color.contentContentSecondary)
            }

            VStack(spacing: theme.sizing.spacingSpacingXs) {
                ForEach(buttons) { button in
                    let themedButton = ThemedButton(text: button.cta, isFullWidth: true, action: button.action)
                    if let accessibilityId = button.accessibilityId {
                        themedButton.accessibilityIdentifier(accessibilityId)
                    } else {
                        themedButton
                    }
                }
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)

            Spacer()
        }
    }
}
