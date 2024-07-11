import Foundation
import SwiftUI

// MARK: - ToolBarButtonSize

public enum ToolBarButtonSize {
    case normal
    case big
}

// MARK: - ThemedToolbarButton

public struct ThemedToolbarButton: View {
    private enum Constants {
        static let iconSizeNormal = 20.0
        static let iconSizeBig = 24.0
        static let buttonWidth = 44.0
        static let buttonHeight = 44.0
        static let titleFontSize = 18.0
    }

    private let text: String?
    private let icon: Icon?
    private let tint: Color
    private let accessibilityId: String
    private let toolBarButtonSize: ToolBarButtonSize
    @Binding private var isDisabled: Bool
    @Binding private var isLoading: Bool
    @Binding private var badgeValue: Int?
    private let action: () -> Void

    public init(icon: Icon?,
                text: String? = nil,
                tint: Color = Colors.primary.mono900,
                isDisabled: Binding<Bool> = .constant(false),
                isLoading: Binding<Bool> = .constant(false),
                badgeValue: Binding<Int?> = .constant(nil),
                accessibilityId: String = "",
                toolBarButtonSize: ToolBarButtonSize = .normal,
                action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.tint = tint
        self.accessibilityId = accessibilityId
        self.toolBarButtonSize = toolBarButtonSize
        _isDisabled = isDisabled
        _isLoading = isLoading
        _badgeValue = badgeValue
        self.action = action
    }

    public var body: some View {
        Button {
            if !isLoading && !isDisabled {
                action()
            }
        } label: {
            if isLoading {
                LoaderView(circleDiameter: .defaultSmall, labelHidden: true)
            } else if let icon {
                icon.image
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(tint)
                    .badgeView(badgeValue: $badgeValue)
            } else if let text {
                Text(text)
                    .font(Font(theme.font.paragraph.normal.withSize(Constants.titleFontSize)))
                    .foregroundStyle(tint)
                    .badgeView(badgeValue: $badgeValue)
            } else {
                EmptyView()
            }
        }
        .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
        .disabled(isDisabled)
        .tint(tint)
        .accessibilityIdentifier(accessibilityId)
        .buttonStyle(.plain)
    }

    private var iconSize: CGFloat {
        toolBarButtonSize == .normal ? Constants.iconSizeNormal : Constants.iconSizeBig
    }
}

#Preview {
    VStack(spacing: 40) {
        ThemedToolbarButton(icon: .bell,
                            action: {})

        ThemedToolbarButton(icon: nil,
                            text: "Help",
                            action: {})

        ThemedToolbarButton(icon: .bell,
                            badgeValue: .constant(1),
                            action: {})

        ThemedToolbarButton(icon: nil,
                            text: "Help",
                            badgeValue: .constant(1),
                            action: {})

        ThemedToolbarButton(icon: .bell,
                            isDisabled: .constant(true),
                            action: {})

        ThemedToolbarButton(icon: nil,
                            text: "Help",
                            isDisabled: .constant(true),
                            action: {})

        ThemedToolbarButton(icon: .bell,
                            isLoading: .constant(true),
                            action: {})
    }
}
