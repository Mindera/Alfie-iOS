import Core
import Models
import SwiftUI

public enum CheckboxState {
    case selected
    case unselected
    case disabled

    var isDisabled: Bool {
        self == .disabled
    }

    // swiftlint:disable vertical_whitespace_between_cases
    public var isSelected: Bool {
        switch self {
        case .selected:
            true
        case .unselected,
             .disabled: // swiftlint:disable:this indentation_width
            false
        }
    }

    var correspondingIcon: ButtonIcon {
        switch self {
        case .selected:
            return ButtonIcon.checkboxSelected
        case .unselected:
            return ButtonIcon.checkboxUnselected
        case .disabled:
            return ButtonIcon.checkboxDisabled
        }
    }

    mutating func toggleIfEnabled() {
        switch self {
        case .selected:
            self = .unselected
        case .unselected:
            self = .selected
        case .disabled:
            break
        }
    }
    // swiftlint:enable vertical_whitespace_between_cases
}

public struct Checkbox: View {
    @Binding private var text: String
    @Binding private var state: CheckboxState
    private let hapticsService: HapticsServiceProtocol

    enum Constants {
        static let iconSize: CGFloat = 24
    }

    public init(
        state: Binding<CheckboxState>,
        text: Binding<String>,
        hapticsService: HapticsServiceProtocol = HapticsService.instance
    ) {
        self._state = state
        self._text = text
        self.hapticsService = hapticsService
    }

    public init(
        state: Binding<CheckboxState>,
        text: String,
        hapticsService: HapticsServiceProtocol = HapticsService.instance
    ) {
        self.init(state: state, text: .constant(text), hapticsService: hapticsService)
    }

    public var body: some View {
        HStack(spacing: Spacing.space150) {
            state.correspondingIcon.image
                .resizable()
                .scaledToFit()
                .frame(width: Constants.iconSize, height: Constants.iconSize)

            Text.build(theme.font.paragraph.normal(text))
        }
        .foregroundStyle(state.isDisabled ? Colors.primary.mono400 : Colors.primary.mono900)
        .onTapGesture {
            playAppropriateHaptics()
            state.toggleIfEnabled()
        }
    }

    private func playAppropriateHaptics() {
        // swiftlint:disable vertical_whitespace_between_cases
        switch state {
        case .selected,
             .unselected: // swiftlint:disable:this indentation_width
            hapticsService.trigger(.selectionChanged)
        case .disabled:
            hapticsService.trigger(.notification(.error))
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#Preview {
    Checkbox(state: .constant(.selected), text: "Selected")
}
