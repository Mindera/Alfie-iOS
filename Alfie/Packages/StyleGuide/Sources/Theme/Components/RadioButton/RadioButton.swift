import Core
import Models
import SwiftUI

public enum RadioButtonState {
    case selected
    case unselected
    case disabled

    var isDisabled: Bool {
        self == .disabled
    }

    var correspondingIcon: ButtonIcon {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .selected:
            return ButtonIcon.radioButtonSelected
        case .unselected:
            return ButtonIcon.radioButtonUnselected
        case .disabled:
            return ButtonIcon.radioButtonDisabled
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

struct RadioButton: View {
    @Binding private var state: RadioButtonState
    @Binding private var text: String
    private let hapticsService: HapticsServiceProtocol

    enum Constants {
        static let iconSize: CGFloat = 21
    }

    public init(
        state: Binding<RadioButtonState>,
        text: Binding<String>,
        hapticsService: HapticsServiceProtocol = HapticsService.instance
    ) {
        self._state = state
        self._text = text
        self.hapticsService = hapticsService
    }

    public init(
        state: Binding<RadioButtonState>,
        text: String,
        hapticsService: HapticsServiceProtocol = HapticsService.instance
    ) {
        self.init(state: state, text: .constant(text))
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
            guard !state.isDisabled else {
                hapticsService.trigger(.notification(.error))
                return
            }

            hapticsService.trigger(.selectionChanged)
            state = .selected
        }
    }
}

#Preview {
    RadioButton(state: .constant(.selected), text: "RadioButton")
}
