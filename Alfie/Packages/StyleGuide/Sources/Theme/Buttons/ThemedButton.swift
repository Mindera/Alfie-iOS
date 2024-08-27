import SwiftUI

// MARK: - ThemedButton

public struct ThemedButton: View {
    private let text: String
    private let type: ButtonType
    private let style: ButtonTheme
    @Binding private var isDisabled: Bool
    @Binding private var isLoading: Bool
    private let leadingAsset: Icon?
    private let trailingAsset: Icon?
    private let action: () -> Void
    private let isFullWidth: Bool

    public init(
        text: String,
        type: ButtonType = .medium,
        style: ButtonTheme = .primary,
        leadingAsset: Icon? = nil,
        trailingAsset: Icon? = nil,
        isDisabled: Binding<Bool> = .constant(false),
        isLoading: Binding<Bool> = .constant(false),
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.type = type
        self.style = style
        self.leadingAsset = leadingAsset
        self.trailingAsset = trailingAsset
        _isDisabled = isDisabled
        _isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }

    public var body: some View {
        Button {
            if !isLoading {
                action()
            }
        } label: {
            HStack(alignment: .center) {
                if isFullWidth {
                    Spacer()
                }
                Text.build(textFor(text))
                    .padding(.horizontal, Constants.horizontalPadding)
                    .padding(.vertical, Constants.verticalPadding)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                if isFullWidth {
                    Spacer()
                }
            }
        }
        .disabled(isDisabled)
        .buttonStyle(
            ThemedButtonStyle(
                style: style,
                type: type,
                isDisabled: isDisabled,
                isLoading: isLoading,
                leadingAsset: leadingAsset,
                trailingAsset: trailingAsset
            )
        )
    }

    func textFor(_ text: String) -> AttributedString {
        switch type {
        case .small:
            // swiftlint:disable vertical_whitespace_between_cases
            switch style {
            case .primary,
                .secondary,
                .tertiary:
                theme.font.small.bold(text)
            case .underline:
                theme.font.small.boldUnderline(text)
            }
            // swiftlint:enable vertical_whitespace_between_cases

        case .medium:
            // swiftlint:disable vertical_whitespace_between_cases
            switch style {
            case .primary,
                .secondary,
                .tertiary:
                theme.font.paragraph.bold(text)
            case .underline:
                theme.font.paragraph.boldUnderline(text)
            }
            // swiftlint:enable vertical_whitespace_between_cases

        case .big:
            // swiftlint:disable vertical_whitespace_between_cases
            switch style {
            case .primary,
                .secondary,
                .tertiary:
                theme.font.header.h3(text)
            case .underline:
                theme.font.header.h3Underline(text)
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }
}

// MARK: - ButtonType

public enum ButtonType {
    case small
    case medium
    case big

    var height: CGFloat {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .small:
            return Constants.smallHeight
        case .medium:
            return Constants.mediumHeight
        case .big:
            return Constants.bigHeight
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

// MARK: - Constants

private enum Constants {
    static let horizontalPadding: CGFloat = 0
    static let verticalPadding: CGFloat = -Spacing.space100
    static let cornerRadius: CGFloat = CornerRadius.s
    static let iconSize: CGFloat = 16
    static let smallHeight: CGFloat = 36
    static let mediumHeight: CGFloat = 44
    static let bigHeight: CGFloat = 52
}

// MARK: - ThemedButtonStyle

private struct ThemedButtonStyle: ButtonStyle {
    let style: ButtonTheme
    let type: ButtonType
    let isDisabled: Bool
    let isLoading: Bool
    let leadingAsset: Icon?
    let trailingAsset: Icon?

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            if let leadingAsset {
                leadingAsset.image
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(textColor(configuration))
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .aspectRatio(contentMode: .fit)
            }
            configuration.label
                .padding(.vertical, Spacing.space200)
            if let trailingAsset {
                trailingAsset.image
                    .renderingMode(.template)
                    .resizable()
                    .tint(textColor(configuration))
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(height: type.height)
        .padding(.horizontal, Spacing.space100)
        .foregroundColor(textColor(configuration))
        .background(background(configuration))
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            ZStack {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor(configuration), lineWidth: 1)

                if isLoading {
                    LoaderView(circleDiameter: .defaultSmall, style: styleLoading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(background(configuration))
                        .cornerRadius(Constants.cornerRadius)
                }
            }
        )
    }

    private func background(_ configuration: Self.Configuration) -> Color {
        let backgroundDisabledColor = style.spec.backgroundDisabledColor
        let backgroundPressedColor = style.spec.backgroundPressedColor
        let backgroundColor = style.spec.backgroundColor

        return isDisabled ? backgroundDisabledColor : configuration.isPressed ? backgroundPressedColor : backgroundColor
    }

    private func textColor(_ configuration: Self.Configuration) -> Color {
        let textDisabledColor = style.spec.textDisabledColor
        let textPressedColor = style.spec.textPressedColor

        return isDisabled ? textDisabledColor : configuration.isPressed ? textPressedColor : style.spec.textColor
    }

    private func borderColor(_ configuration: Self.Configuration) -> Color {
        let borderDisabledColor = style.spec.borderDisabledColor
        let borderPressedColor = style.spec.borderPressedColor

        return isDisabled ? borderDisabledColor : configuration.isPressed ? borderPressedColor : style.spec.borderColor
    }

    private var styleLoading: LoaderView.CircleStyle {
        style == .primary && !isDisabled ? . light : .dark
    }
}

#Preview("Button Primary") {
    VStack {
        ThemedButton(text: "Primary") {}
        ThemedButton(text: "Primary", leadingAsset: .chevronLeft) {}
        ThemedButton(text: "Primary", trailingAsset: .chevronRight) {}
        ThemedButton(text: "Primary", leadingAsset: .heart, trailingAsset: .chevronRight, isLoading: .constant(true)) {}
        ThemedButton(text: "Primary", leadingAsset: .heart, trailingAsset: .chevronRight, isDisabled: .constant(true)) {
        }
    }
}

#Preview("Button Secondary") {
    VStack {
        ThemedButton(text: "Secondary", style: .secondary) {}
        ThemedButton(text: "Secondary", style: .secondary, leadingAsset: .chevronLeft) {}
        ThemedButton(text: "Secondary", style: .secondary, trailingAsset: .chevronRight, isLoading: .constant(true)) {}
        ThemedButton(text: "Secondary", style: .secondary, leadingAsset: .heart, trailingAsset: .chevronRight) {}
        ThemedButton(
            text: "Secondary",
            style: .secondary,
            leadingAsset: .heart,
            trailingAsset: .chevronRight,
            isDisabled: .constant(true),
            isLoading: .constant(true)
        ) {}
    }
}

#Preview("Button Tertiary") {
    VStack {
        ThemedButton(text: "Tertiary", style: .tertiary) {}
        ThemedButton(text: "Tertiary", style: .tertiary, leadingAsset: .chevronLeft) {}
        ThemedButton(text: "Tertiary", style: .tertiary, trailingAsset: .chevronRight) {}
        ThemedButton(text: "Tertiary", style: .tertiary, leadingAsset: .heart, trailingAsset: .chevronRight) {}
        ThemedButton(
            text: "Tertiary",
            style: .tertiary,
            leadingAsset: .heart,
            trailingAsset: .chevronRight,
            isDisabled: .constant(true)
        ) {}
    }
}

#Preview("Button underline") {
    VStack {
        ThemedButton(text: "Underline", style: .underline) {}
        ThemedButton(text: "Underline", style: .underline, leadingAsset: .chevronLeft) {}
        ThemedButton(text: "Underline", style: .underline, trailingAsset: .chevronRight) {}
        ThemedButton(text: "Underline", style: .underline, leadingAsset: .heart, trailingAsset: .chevronRight) {}
        ThemedButton(
            text: "Underline",
            style: .underline,
            leadingAsset: .heart,
            trailingAsset: .chevronRight,
            isDisabled: .constant(true)
        ) {}
    }
}

extension ThemedButton: CustomShimmerable {
    public var cornerRadius: CGFloat {
        switch style {
        case .primary,
             .secondary: // swiftlint:disable:this indentation_width
            return Constants.cornerRadius
        case .tertiary,
             .underline: // swiftlint:disable:this indentation_width
            return 0
        }
    }

    public var customLighterShimmerColor: Color? {
        switch style {
        case .primary:
            return Colors.primary.mono600
        case .secondary,
             .tertiary, // swiftlint:disable:this indentation_width
             .underline:
            return nil
        }
    }

    public var customDarkerShimmerColor: Color? {
        switch style {
        case .primary:
            return Colors.primary.mono900
        case .secondary,
             .tertiary, // swiftlint:disable:this indentation_width
             .underline:
            return nil
        }
    }
}
