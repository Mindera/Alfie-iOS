import SwiftUI

// MARK: - ThemedSearchBarView

public struct ThemedSearchBarView: View {
    public enum Theme: CaseIterable {
        case light
        case dark
        case soft
        case softLarge

        // swiftlint:disable vertical_whitespace_between_cases
        var focusedBackgroundColor: Color {
            switch self {
            case .soft,
                .softLarge,
                .light:
                Colors.primary.mono050
            case .dark:
                Colors.primary.mono800
            }
        }

        var unfocusedBackgroundColor: Color {
            switch self {
            case .soft,
                .softLarge,
                .dark:
                focusedBackgroundColor
            case .light:
                Colors.primary.white
            }
        }

        var focusedBorderColor: Color {
            switch self {
            case .soft,
                .softLarge:
                Colors.primary.mono200
            case .light:
                Colors.primary.mono900
            case .dark:
                Colors.primary.mono300
            }
        }

        var unfocusedBorderColor: Color {
            switch self {
            case .soft,
                .softLarge,
                    .dark:
                    .clear
            case .light:
                Colors.primary.mono900
            }
        }

        var searchTermColor: Color {
            switch self {
            case .soft,
                .softLarge,
                .light:
                Colors.primary.mono900
            case .dark:
                Colors.primary.mono050
            }
        }

        var placeholderColor: Color {
            switch self {
            case .soft,
                .softLarge,
                .light:
                Colors.primary.mono500
            case .dark:
                Colors.primary.mono200
            }
        }

        var cursorColor: Color {
            searchTermColor
        }

        var iconColor: Color {
            switch self {
            case .soft,
                .softLarge,
                .light:
                Colors.primary.mono900
            case .dark:
                Colors.primary.mono200
            }
        }

        var searchBarHeight: CGFloat {
            switch self {
            case .soft,
                .light:
                32
            case .dark:
                38
            case .softLarge:
                44
            }
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    public enum AutoFocusSetting {
        case on(delay: CGFloat)
        case off
    }

    public struct DismissConfiguration {
        public enum DismissType: Equatable {
            case back
            case cancel(title: String)
            case hidden
        }

        let type: DismissType
        let accessibilityId: String

        public init(type: DismissType = .back, accessibilityId: String? = nil) {
            self.type = type
            self.accessibilityId = accessibilityId ?? AccessibilityId.cancelAccessibilityId
        }

        var isCancelType: Bool {
            guard case .cancel = type else { return false }
            return true
        }
    }

    @Binding private var searchText: String
    // We cannot use the binding above otherwise it won't trigger the onChange if used outside a view
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    @State private var isCancelButtonVisible = false
    @State private var isClearButtonVisible = false

    private let defaultPlaceholder: String
    private let focusedPlaceholder: String
    private let dismissConfiguration: DismissConfiguration
    private let theme: Theme
    private let keyboardType: UIKeyboardType
    private let submitLabel: SubmitLabel
    private let autocorrectionDisabled: Bool
    private let autoFocusWhenAppearing: AutoFocusSetting
    private let inputAccessibilityId: String
    private let clearAccessibilityId: String
    public let onCancelTap: (() -> Void)?
    public let onClearTap: (() -> Void)?
    public let onSubmitTap: (() -> Void)?
    public let onFocusChange: ((Bool) -> Void)?

    private var currentPlaceholder: String {
        isFocused ? focusedPlaceholder : defaultPlaceholder
    }

    public init(
        searchText: Binding<String>,
        placeholder: String,
        placeholderOnFocus: String? = nil,
        theme: Theme,
        dismissConfiguration: DismissConfiguration,
        keyboardType: UIKeyboardType = .default,
        submitLabel: SubmitLabel = .done,
        autocorrectionDisabled: Bool = true,
        autoFocusWhenAppearing: AutoFocusSetting = .off,
        inputAccessibilityId: String? = nil,
        clearAccessibilityId: String? = nil,
        onCancelTap: (() -> Void)? = nil,
        onClearTap: (() -> Void)? = nil,
        onSubmitTap: (() -> Void)? = nil,
        onFocusChange: ((Bool) -> Void)? = nil
    ) {
        _searchText = searchText
        defaultPlaceholder = placeholder
        focusedPlaceholder = placeholderOnFocus ?? defaultPlaceholder
        self.theme = theme
        self.dismissConfiguration = dismissConfiguration
        self.keyboardType = keyboardType
        self.submitLabel = submitLabel
        self.autocorrectionDisabled = autocorrectionDisabled
        self.autoFocusWhenAppearing = autoFocusWhenAppearing
        self.inputAccessibilityId = inputAccessibilityId ?? AccessibilityId.inputAccessibilityId
        self.clearAccessibilityId = clearAccessibilityId ?? AccessibilityId.clearAccessibilityId
        self.onCancelTap = onCancelTap
        self.onClearTap = onClearTap
        self.onSubmitTap = onSubmitTap
        self.onFocusChange = onFocusChange
    }

    private enum Constants {
        static let autoFocusTimeDelay: CGFloat = 0
        static let borderLineWidth: CGFloat = 1
        static let trailingIconSize: CGFloat = 16
        static let cancelIconSize: CGFloat = 16
    }

    public var body: some View {
        HStack {
            if isCancelButtonVisible && dismissConfiguration.type == .back {
                cancelButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            HStack {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(currentPlaceholder)
                        .font(Font(theme.font.paragraph.normal))
                        .foregroundColor(theme.placeholderColor)
                )
                .focused($isFocused)
                .tint(theme.cursorColor)
                .foregroundStyle(theme.searchTermColor)
                .keyboardType(keyboardType)
                .submitLabel(submitLabel)
                .font(Font(theme.font.paragraph.normal))
                .autocorrectionDisabled(autocorrectionDisabled)
                .accessibilityRepresentation {
                    TextField(text: $text) {
                        Text(currentPlaceholder)
                    }
                    .accessibilityIdentifier(inputAccessibilityId)
                }
                // Make sure this is set before the clearButton overlay to avoid overwriting
                .onTapGesture {
                    isFocused = true
                }
                .overlay(textFieldOverlayIcon, alignment: .trailing)
                .onAppear {
                    guard case .on(let delay) = autoFocusWhenAppearing else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        isFocused = true
                    }
                }
                .onChange(of: isFocused) { newValue in
                    isCancelButtonVisible = newValue && dismissConfiguration.type != .hidden
                    onFocusChange?(newValue)
                }
                .onChange(of: text) { newValue in
                    isClearButtonVisible = !newValue.isEmpty
                    searchText = newValue
                }
                .onSubmit {
                    onSubmitTap?()
                }
            }
            .padding(Spacing.space200)
            .frame(height: theme.searchBarHeight)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.full)
                        .fill(isFocused ? theme.focusedBackgroundColor : theme.unfocusedBackgroundColor)

                    RoundedRectangle(cornerRadius: CornerRadius.full)
                        .inset(by: Constants.borderLineWidth)
                        .stroke(
                            isFocused ? theme.focusedBorderColor : theme.unfocusedBorderColor,
                            lineWidth: Constants.borderLineWidth
                        )
                        .padding(-Constants.borderLineWidth)
                }
            )

            if isCancelButtonVisible && dismissConfiguration.isCancelType {
                cancelButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(height: theme.searchBarHeight)
        .animation(.standardDecelerate, value: isCancelButtonVisible)
        .animation(.emphasizedAccelerate, value: isClearButtonVisible)
    }

    private var clearButton: some View {
        configured(trailingImage: Icon.close.image)
            .onTapGesture {
                text = ""
                searchText = ""
                onClearTap?()
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(clearAccessibilityId)
    }

    private var magnifyingGlassIcon: some View {
        configured(trailingImage: Icon.search.image)
    }

    @ViewBuilder private var textFieldOverlayIcon: some View {
        if isClearButtonVisible {
            clearButton
        } else {
            magnifyingGlassIcon
        }
    }

    private func configured(trailingImage image: Image) -> some View {
        image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.trailingIconSize, height: Constants.trailingIconSize)
            .foregroundStyle(theme.iconColor)
            .transition(.scale(scale: 0, anchor: .trailing))
    }

    @ViewBuilder private var cancelButton: some View {
        let dismissBlock = {
            isFocused = false
            text = ""
            searchText = ""
            onCancelTap?()
        }

        switch dismissConfiguration.type {
        case .back:
            Button {
                dismissBlock()
            } label: {
                Icon.arrowLeft.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .tint(Colors.primary.mono900)
                    .frame(size: Constants.cancelIconSize)
            }
            .accessibilityIdentifier(dismissConfiguration.accessibilityId)

        case .cancel(let title):
            Button {
                dismissBlock()
            } label: {
                Text.build(theme.font.small.normal(title))
                    .foregroundStyle(Colors.primary.mono900)
                    .accessibilityIdentifier(dismissConfiguration.accessibilityId)
            }

        case .hidden:
            EmptyView()
        }
    }
}

// MARK: - Accessibility

private enum AccessibilityId {
    static let inputAccessibilityId: String = "search-input"
    static let clearAccessibilityId: String = "close-btn"
    static let cancelAccessibilityId: String = "back-btn"
}

// MARK: - ThemedSearchBarRightIconModifier

struct ThemedSearchBarRightIconModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .background(.blue)
            .clipShape(.rect(cornerRadius: 10))
    }
}

@available(iOS 17, *)
#Preview {
    VStack {
        Text("Soft")
        ThemedSearchBarView(
            searchText: .constant(""),
            placeholder: "Search Alfie",
            placeholderOnFocus: "What are you looking for?",
            theme: .soft,
            dismissConfiguration: .init(type: .back)
        )
        .padding()

        Spacer()

        Text("SoftLarge")
        ThemedSearchBarView(
            searchText: .constant(""),
            placeholder: "Search Alfie",
            placeholderOnFocus: "What are you looking for?",
            theme: .softLarge,
            dismissConfiguration: .init(type: .cancel(title: "Cancel"))
        )
        .padding()

        Spacer()

        Text("Light")
        ThemedSearchBarView(
            searchText: .constant(""),
            placeholder: "Search Alfie",
            placeholderOnFocus: "What are you looking for?",
            theme: .light,
            dismissConfiguration: .init(type: .back)
        )
        .padding()

        Spacer()

        Text("Dark")
        ThemedSearchBarView(
            searchText: .constant(""),
            placeholder: "Search Alfie",
            placeholderOnFocus: "What are you looking for?",
            theme: .dark,
            dismissConfiguration: .init(type: .back)
        )
        .padding()
    }
} // swiftlint:disable:this file_length
