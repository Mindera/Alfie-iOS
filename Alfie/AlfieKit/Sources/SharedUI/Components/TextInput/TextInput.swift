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
    public let accessibilityIdentifier: String?
    public let accessibilityLabel: String?

    public init(
        text: Binding<String>,
        label: String? = nil,
        placeholder: String? = nil,
        prefix: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isError: Bool = false,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.prefix = prefix
        self.keyboardType = keyboardType
        self.isError = isError
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - TextInput

/// Bordered single-line field with an optional label and an optional leading affix.
///
/// Distinct from `ThemedInput`, which is the legacy-design input (legacy `Primitives` palette,
/// focus bar, status-label row) still used by the DebugMenu. This one is the modern-design
/// component: semantic `Theme` tokens, and an affix the design places beside the value.
public struct TextInput: View {
    private let configuration: TextInputConfiguration
    @FocusState private var isFocused: Bool

    public init(configuration: TextInputConfiguration) {
        self.configuration = configuration
    }

    private var style: TextInputStyle {
        TextInputStyle(isError: configuration.isError, isFocused: isFocused)
    }

    public var body: some View {
        let style = self.style

        return VStack(alignment: .leading, spacing: theme.spacing.space100) {
            if let label = configuration.label {
                Text.build(theme.font.body.small(label))
                    .foregroundStyle(style.labelColor)
            }

            HStack(spacing: theme.spacing.space050) {
                if let prefix = configuration.prefix {
                    Text.build(theme.font.body.medium(prefix))
                        .foregroundStyle(style.prefixColor)
                        .accessibilityHidden(true)
                }

                TextField(
                    "",
                    text: configuration.$text,
                    prompt: configuration.placeholder.map { placeholder in
                        Text(placeholder)
                            .font(Font(theme.font.body.medium.uiFont))
                            .foregroundColor(style.placeholderColor)
                    }
                )
                .font(Font(theme.font.body.medium.uiFont))
                .foregroundStyle(style.textColor)
                .tint(Theme.contentContentPrimary)
                .keyboardType(configuration.keyboardType)
                .focused($isFocused)
                .accessibilityIdentifier(configuration.accessibilityIdentifier ?? "")
                .accessibilityLabel(configuration.accessibilityLabel ?? configuration.label ?? "")
            }
            .padding(.horizontal, theme.spacing.space150)
            .frame(height: TextInputStyle.height)
            .background(
                RoundedRectangle(cornerRadius: Sizing.radiusSoft)
                    .strokeBorder(style.borderColor, lineWidth: style.borderWidth)
                    .background(RoundedRectangle(cornerRadius: Sizing.radiusSoft).fill(style.backgroundColor))
            )
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
    }
}

// MARK: - TextInputStyle

/// Resolves a `TextInput`'s visual styling from its state, sourced from design tokens.
/// Extracted from `TextInput` so the state→token mapping is unit-testable without snapshots.
struct TextInputStyle {
    static let height: CGFloat = 44

    private enum Constants {
        static let borderFocused: CGFloat = 2
    }

    let isError: Bool
    let isFocused: Bool

    var borderColor: Color {
        if isError {
            return Theme.contentContentNegative
        } else if isFocused {
            return Theme.contentContentPrimary
        } else {
            return Theme.borderSoft
        }
    }

    var borderWidth: CGFloat {
        isFocused || isError ? Constants.borderFocused : Primitives.Border.borderWeightDefault
    }

    var backgroundColor: Color {
        Theme.surfaceBackgroundPrimary
    }

    var textColor: Color {
        Theme.contentContentPrimary
    }

    /// The affix is chrome, not content — it stays muted so the typed value reads as the value.
    var prefixColor: Color {
        Theme.contentContentTerciary
    }

    var placeholderColor: Color {
        Theme.contentContentTerciary
    }

    var labelColor: Color {
        isError ? Theme.contentContentNegative : Theme.contentContentTerciary
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
