import SwiftUI

public struct RadioButtonList<SelectionValue>: View
where SelectionValue: Hashable & RawRepresentable, SelectionValue.RawValue == String {
    @Binding private var disabledValues: [SelectionValue]
    @Binding private var selectedValue: SelectionValue?
    private var values: [SelectionValue]
    private let verticalSpacing: CGFloat

    ///  Provides a list of RadioButtons with the built in behavior to make sure only one is selected at any given time
    /// - Parameters:
    ///   - values: The values to display as radio buttons. **These must be enum cases whose rawValue is a String**
    ///   - disabledValues: The values that should appear as disabled buttons. These can change in runtime, if needed.
    ///   - selectedValue: The current selected value of the list. **Set it to nil if you don't want any value selected by default**
    ///   - verticalSpacing: The vertical spacing of the radioButtons along the VStack; default is 16
    public init(
        values: [SelectionValue],
        disabledValues: Binding<[SelectionValue]> = .constant([]),
        selectedValue: Binding<SelectionValue?>,
        verticalSpacing: CGFloat = Spacing.space200
    ) {
        self.values = values
        self._disabledValues = disabledValues
        self._selectedValue = selectedValue
        self.verticalSpacing = verticalSpacing
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            ForEach(values, id: \.self) { value in
                RadioButton(state: binding(for: value), text: value.rawValue)
            }
        }
    }

    private func binding(for value: SelectionValue) -> Binding<RadioButtonState> {
        .init {
            guard !disabledValues.contains(value) else {
                return .disabled
            }

            return selectedValue == value ? .selected : .unselected
        } set: { _ in
            selectedValue = value
        }
    }
}

#Preview {
    RadioButtonList(
        values: PreviewTestValues.allCases,
        disabledValues: .constant([.selection3]),
        selectedValue: .constant(.selection1)
    )
}

private enum PreviewTestValues: String, CaseIterable {
    case selection1
    case selection2
    case selection3
}
