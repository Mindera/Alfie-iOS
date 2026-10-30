import SwiftUI

// MARK: - TextInputConfiguration

public struct TextInputConfiguration {
    @Binding public var text: String
    public let label: String?
    public let placeholder: String?
    /// Rendered inside the border, before the field. A currency glyph in the price filter's
    /// use, but the component stays domain-agnostic — any short affix works.
    public let prefix: String?
    public let keyboardType: UIKeyboardType
    public let isError: Bool
    public let isSecure: Bool
    public let accessibilityIdentifier: String?
    public let accessibilityLabel: String?

    public init(
        text: Binding<String>,
        label: String? = nil,
        placeholder: String? = nil,
        prefix: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isError: Bool = false,
        isSecure: Bool = false,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.prefix = prefix
        self.keyboardType = keyboardType
        self.isError = isError
        self.isSecure = isSecure
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - TextInput

/// Bordered single-line field with an optional label and an optional leading affix.
public struct TextInput: View {
    private let configuration: TextInputConfiguration
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled

    public init(configuration: TextInputConfiguration) {
        self.configuration = configuration
    }

    private var style: TextInputStyle {
        TextInputStyle(isError: configuration.isError, isFocused: isFocused, isDisabled: !isEnabled)
    }

    public var body: some View {
        let style = self.style

        return VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
            if let label = configuration.label {
                Text.build(theme.font.body.small(label))
                    .foregroundStyle(style.labelColor)
            }

            HStack(spacing: theme.sizing.spacingSpacing2xs) {
                if let prefix = configuration.prefix {
                    Text.build(theme.font.body.medium(prefix))
                        .foregroundStyle(style.prefixColor)
                        .accessibilityHidden(true)
                }

                field(prompt: configuration.placeholder.map { placeholder in
                    Text(placeholder)
                        .font(Font(theme.font.body.medium.uiFont))
                        .foregroundColor(style.placeholderColor)
                })
                .font(Font(theme.font.body.medium.uiFont))
                .foregroundStyle(style.textColor)
                .tint(theme.color.contentContentPrimary)
                .keyboardType(configuration.keyboardType)
                .focused($isFocused)
                .accessibilityIdentifier(configuration.accessibilityIdentifier ?? "")
                // Applied only when supplied — an empty override would silence the field's own
                // announcement and leave an unlabelled input.
                .modifier(
                    OptionalAccessibilityLabel(
                        label: configuration.accessibilityLabel ?? configuration.label
                    )
                )
            }
            .padding(.horizontal, theme.sizing.spacingSpacingSm)
            .frame(height: TextInputStyle.height)
            .background(
                RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
                    .strokeBorder(style.borderColor, lineWidth: style.borderWidth)
                    .background(RoundedRectangle(cornerRadius: theme.sizing.radiusSoft).fill(style.backgroundColor))
            )
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
    }

    @ViewBuilder
    private func field(prompt: Text?) -> some View {
        if configuration.isSecure {
            SecureField("", text: configuration.$text, prompt: prompt)
        } else {
            TextField("", text: configuration.$text, prompt: prompt)
        }
    }
}

/// Applies an accessibility label only when one exists, so an unlabelled `TextInput` keeps the
/// system's own announcement instead of being overridden with an empty string.
private struct OptionalAccessibilityLabel: ViewModifier {
    let label: String?

    func body(content: Content) -> some View {
        if let label, !label.isEmpty {
            content.accessibilityLabel(label)
        } else {
            content
        }
    }
}

// MARK: - TextInputStyle

/// Resolves a `TextInput`'s visual styling from its state, sourced from design tokens.
/// Extracted from `TextInput` so the state→token mapping is unit-testable without snapshots.
struct TextInputStyle: ThemeReading {
    static let height: CGFloat = 44

    private enum Constants {
        static let borderFocused: CGFloat = 2
    }

    let isError: Bool
    let isFocused: Bool
    let isDisabled: Bool

    init(isError: Bool, isFocused: Bool, isDisabled: Bool = false) {
        self.isError = isError
        self.isFocused = isFocused
        self.isDisabled = isDisabled
    }

    var borderColor: Color {
        if isDisabled {
            return theme.color.borderSoft
        } else if isError {
            return theme.color.contentContentNegative
        } else if isFocused {
            return theme.color.contentContentPrimary
        } else {
            return theme.color.borderSoft
        }
    }

    var borderWidth: CGFloat {
        !isDisabled && (isFocused || isError) ? Constants.borderFocused : theme.sizing.borderBorderWeightDefault
    }

    var backgroundColor: Color {
        theme.color.surfaceBackgroundPrimary
    }

    var textColor: Color {
        isDisabled ? theme.color.contentContentPrimaryDisabled : theme.color.contentContentPrimary
    }

    /// The affix is chrome, not content — it stays muted so the typed value reads as the value.
    var prefixColor: Color {
        isDisabled ? theme.color.contentContentPrimaryDisabled : theme.color.contentContentTerciary
    }

    var placeholderColor: Color {
        theme.color.contentContentTerciary
    }

    var labelColor: Color {
        if isDisabled {
            return theme.color.contentContentPrimaryDisabled
        }
        return isError ? theme.color.contentContentNegative : theme.color.contentContentTerciary
    }
}

#Preview {
    struct Harness: View {
        @State private var minimum = "40"
        @State private var maximum = ""

        var body: some View {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    TextInput(
                        configuration: .init(
                            text: $minimum,
                            label: "Min",
                            placeholder: "8",
                            prefix: "£",
                            keyboardType: .numberPad
                        )
                    )
                    TextInput(
                        configuration: .init(
                            text: $maximum,
                            label: "Max",
                            placeholder: "480",
                            prefix: "£",
                            keyboardType: .numberPad
                        )
                    )
                }
                TextInput(
                    configuration: .init(
                        text: .constant("500"),
                        label: "Min",
                        prefix: "£",
                        keyboardType: .numberPad,
                        isError: true
                    )
                )
            }
            .padding(24)
        }
    }
    return Harness()
}
