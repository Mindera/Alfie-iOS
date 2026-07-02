import SwiftUI

// MARK: - ThemedInput

public struct ThemedInput: View {
    @Binding private var text: String
    private let title: String?
    private let placeholder: String?
    private let status: InputStatus
    @Binding private var isDisabled: Bool
    @Binding private var isRequired: Bool
    private let limit: Int?
    private let icon: Icon?

    public init(
        _ text: Binding<String>,
        title: String? = nil,
        placeholder: String? = nil,
        status: InputStatus = .empty,
        limit: Int? = nil,
        isDisabled: Binding<Bool> = .constant(false),
        isRequired: Binding<Bool> = .constant(false),
        icon: Icon? = nil
    ) {
        _text = text
        self.title = title
        self.placeholder = placeholder
        self.status = status
        self.limit = limit
        _isDisabled = isDisabled
        _isRequired = isRequired
        self.icon = icon
    }

    public var body: some View {
        TextField("\(placeholder ?? "")", text: $text)
            .textFieldStyle(
                ThemedTextStyle(
                    title: title,
                    status: status,
                    isDisabled: isDisabled,
                    isRequired: isRequired,
                    limit: limit,
                    count: .init(get: { text.count }, set: { _ in }),
                    icon: icon
                )
            )
            .onChange(of: text) { newValue in
                guard let limit else { return }
                text = "\(newValue.prefix(limit))"
            }
    }
}

// MARK: - ThemedTextStyle

private struct ThemedTextStyle: TextFieldStyle {
    @FocusState var isFocused: Bool
    var title: String?
    var status: InputStatus
    var isDisabled: Bool
    var isRequired: Bool
    var limit: Int?
    var icon: Icon?
    @Binding var count: Int
    private let theme: DesignSystemProtocol = DesignSystem.shared

    init(title: String? = nil, status: InputStatus, isDisabled: Bool, isRequired: Bool, limit: Int? = nil, count: Binding<Int> = .constant(0), icon: Icon? = nil) {
        self.title = title
        self.status = status
        self.limit = limit
        _count = count
        self.isDisabled = isDisabled
        self.isRequired = isRequired
        self.icon = icon
    }

    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing0) {
            if title != nil || limit != nil {
                HStack(spacing: Primitives.Spacing.spacing0) {
                    if let title {
                        Text.build(theme.font.body.medium(title))
                            .lineLimit(1)
                            .foregroundStyle(isDisabled ? Primitives.Colours.neutrals200 : Primitives.Colours.neutrals500)
                    }
                    if isRequired {
                        Text.build(theme.font.body.medium("*"))
                            .foregroundStyle(isDisabled ? Primitives.Colours.neutrals200 : Primitives.Colours.semanticError700)
                            .padding(.leading, Primitives.Spacing.spacing2)
                    }
                    if let limit {
                        Spacer()
                        Text.build(theme.font.body.medium("\(count)/\(limit)"))
                            .foregroundStyle(isDisabled ? Primitives.Colours.neutrals200 : Primitives.Colours.neutrals500)
                    }
                }
                .padding(.bottom, Primitives.Spacing.spacing8)
            }
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: RoundedCornerStyle.continuous)
                    .stroke(barColor, lineWidth: 1.5)
                    .background(Primitives.Colours.neutrals0)
                    .frame(height: Constants.inputHeight)
                HStack(spacing: Primitives.Spacing.spacing0) {
                    configuration.body
                        .font(Font(theme.font.body.medium.uiFont))
                        .accentColor(Primitives.Colours.neutrals800)
                        .focused($isFocused)
                        .disabled(isDisabled)
                        .foregroundStyle(isDisabled ? Primitives.Colours.neutrals200 : Primitives.Colours.neutrals800)
                        .padding(.leading, Constants.inputPadding)
                        .padding(.trailing, icon != nil ? Constants.inputIconPadding : Constants.inputPadding)
                        .frame(height: Constants.inputHeight)
                    if let icon {
                        icon.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .padding(.trailing, Constants.inputPadding)
                            .foregroundStyle(isDisabled ? Primitives.Colours.neutrals200 : Primitives.Colours.neutrals800)
                    }
                }
            }
            .frame(height: Constants.inputHeight)
            if status.hasInfo {
                statusLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Primitives.Spacing.spacing4)
            }
        }
    }

    @ViewBuilder var statusLabel: some View {
        switch status {
        case .empty:
            EmptyView()

        case .info(let string):
            Text.build(theme.font.body.small(string))
                .foregroundStyle(shouldApplyDisabledColor(for: Primitives.Colours.neutrals500))
                .lineLimit(2)

        case .success(let string):
            HStack(alignment: .top, spacing: Primitives.Spacing.spacing2) {
                Icon.checkmark.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundStyle(shouldApplyDisabledColor(for: Primitives.Colours.semanticSuccess800))
                Text.build(theme.font.body.small(string))
                    .foregroundStyle(shouldApplyDisabledColor(for: Primitives.Colours.semanticSuccess800))
                    .lineLimit(2)
            }

        case .error(let string):
            HStack(alignment: .top, spacing: Primitives.Spacing.spacing2) {
                Icon.info.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundStyle(shouldApplyDisabledColor(for: Primitives.Colours.semanticError700))
                Text.build(theme.font.body.small(string))
                    .foregroundStyle(shouldApplyDisabledColor(for: Primitives.Colours.semanticError700))
                    .lineLimit(2)
            }
        }
    }

    private func shouldApplyDisabledColor(for color: Color) -> Color {
        color.opacity(isDisabled ? Constants.isDisableOpacity : 1)
    }

    private var barColor: Color {
        switch status {
        case .empty,
             .info: // swiftlint:disable:this indentation_width
            return isDisabled
                ? Primitives.Colours.neutrals200
                : !isFocused ? Primitives.Colours.neutrals400 : Primitives.Colours.neutrals800

        case .success:
            return shouldApplyDisabledColor(for: Primitives.Colours.semanticSuccess800)

        case .error:
            return shouldApplyDisabledColor(for: Primitives.Colours.semanticError700)
        }
    }
}

// MARK: - Constants

private enum Constants {
    static var barHeight: CGFloat = 2
    static var cornerRadius: CGFloat = Sizing.radiusSoft
    static var isDisableOpacity: CGFloat = 0.3
    static var inputPadding: CGFloat = Primitives.Spacing.spacing8
    static var inputIconPadding: CGFloat = Primitives.Spacing.spacing2
    static var iconSize: CGFloat = 16
    static var inputHeight: CGFloat = 44
}

// MARK: - InputStatus

public enum InputStatus {
    case empty
    case info(String)
    case success(String)
    case error(String)

    var hasInfo: Bool {
        if case .empty = self {
            false
        } else {
            true
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            Spacer()
            ThemedInput(.constant("Text"))
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(.constant(""), title: "Title", placeholder: "E.g. John")
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(
                .constant("Text"),
                title: "Title",
                status: .info(
                    "Must be at least 8 characters long and include 1 number. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasell ma ligula" // swiftlint:disable:this line_length
                )
            )
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(
                .constant("Text"),
                title: "Title",
                status: .success("Must be at least 8 characters long and include 1 number.")
            )
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(
                .constant("Text"),
                title: "Title",
                status: .error("Must be at least 8 characters long and include 1 number.")
            )
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(
                .constant("Text"),
                title: "Title",
                status: .info("Must be at least 8 characters long and include 1 number."),
                isDisabled: .constant(true)
            )
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(
                .constant("Text"),
                title: "Title",
                status: .success("Must be at least 8 characters long and include 1 number."),
                isDisabled: .constant(true)
            )
            Spacer()
            ThemedDivider.horizontalThin
            Spacer()
            ThemedInput(
                .constant("Text"),
                title: "Title",
                status: .error("Must be at least 8 characters long and include 1 number."),
                isDisabled: .constant(true)
            )
        }
        .padding(.horizontal, 16)
    }
}
