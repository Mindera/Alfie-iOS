import SwiftUI

public struct QuantityStepper: View {
    /// Both come from the caller because both are screen-scoped: the component cannot know which
    /// screen it is on, and two steppers sharing one identifier are indistinguishable to a UI test.
    public struct Accessibility {
        public struct Control {
            let label: String
            let identifier: String

            public init(label: String, identifier: String) {
                self.label = label
                self.identifier = identifier
            }
        }

        let value: Control
        let decrease: Control
        let increase: Control

        public init(value: Control, decrease: Control, increase: Control) {
            self.value = value
            self.decrease = decrease
            self.increase = increase
        }
    }

    private enum Constants {
        static let iconSize: CGFloat = Sizing.iconsIconSmall
        static let minTapTarget: CGFloat = 44
    }

    private let quantity: Int
    private let bounds: ClosedRange<Int>
    private let isDisabled: Bool
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let accessibility: Accessibility
    private let onDecrease: () -> Void
    private let onIncrease: () -> Void

    public init(
        quantity: Int,
        bounds: ClosedRange<Int>,
        isDisabled: Bool = false,
        height: CGFloat = Primitives.Spacing.spacing40,
        cornerRadius: CGFloat = Sizing.radiusSoft,
        accessibility: Accessibility,
        onDecrease: @escaping () -> Void,
        onIncrease: @escaping () -> Void
    ) {
        self.quantity = quantity
        self.bounds = bounds
        self.isDisabled = isDisabled
        self.height = height
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
        self.onDecrease = onDecrease
        self.onIncrease = onIncrease
    }

    public var body: some View {
        HStack(spacing: Primitives.Spacing.spacing0) {
            stepButton(
                icon: .minus,
                control: accessibility.decrease,
                isEnabled: quantity > bounds.lowerBound,
                action: onDecrease
            )

            Text.build(theme.font.body.medium(String(quantity)))
                .foregroundStyle(contentColor(isEnabled: true))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .accessibilityLabel(accessibility.value.label)
                .accessibilityIdentifier(accessibility.value.identifier)

            stepButton(
                icon: .plus,
                control: accessibility.increase,
                isEnabled: quantity < bounds.upperBound,
                action: onIncrease
            )
        }
        .frame(height: height)
        .background(Theme.buttonPrimaryBackgroundPrimaryDefault)
        .cornerRadius(cornerRadius)
        .accessibilityElement(children: .contain)
    }

    private func stepButton(
        icon: Icon,
        control: Accessibility.Control,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            icon.image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .frame(width: Constants.minTapTarget, height: height)
                .foregroundStyle(contentColor(isEnabled: isEnabled))
                .contentShape(Rectangle())
        }
        .disabled(isDisabled || !isEnabled)
        .accessibilityLabel(control.label)
        .accessibilityIdentifier(control.identifier)
    }

    private func contentColor(isEnabled: Bool) -> Color {
        isDisabled || !isEnabled
            ? Theme.buttonPrimaryContentPrimaryDisabled
            : Theme.buttonPrimaryContentPrimaryDefault
    }
}

// MARK: - Previews

#if DEBUG
private extension QuantityStepper.Accessibility {
    static func preview(quantity: Int, decrease: String) -> Self {
        Self(
            value: .init(label: "Quantity: \(quantity)", identifier: "preview.quantity.value.label"),
            decrease: .init(label: decrease, identifier: "preview.quantity.decrease.button"),
            increase: .init(label: "Increase", identifier: "preview.quantity.increase.button")
        )
    }
}

#Preview("Quantity stepper") {
    VStack(spacing: Primitives.Spacing.spacing16) {
        QuantityStepper(
            quantity: 1,
            bounds: 0...100,
            accessibility: .preview(quantity: 1, decrease: "Remove")
        ) {} onIncrease: {}

        QuantityStepper(
            quantity: 100,
            bounds: 0...100,
            accessibility: .preview(quantity: 100, decrease: "Decrease")
        ) {} onIncrease: {}

        QuantityStepper(
            quantity: 3,
            bounds: 0...100,
            isDisabled: true,
            accessibility: .preview(quantity: 3, decrease: "Decrease")
        ) {} onIncrease: {}
    }
    .padding()
}
#endif
