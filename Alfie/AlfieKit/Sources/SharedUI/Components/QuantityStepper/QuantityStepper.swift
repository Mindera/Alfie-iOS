import SwiftUI

// MARK: - QuantityStepper

public struct QuantityStepper: View {
    public struct AccessibilityLabels {
        let value: String
        let decrease: String
        let increase: String

        public init(value: String, decrease: String, increase: String) {
            self.value = value
            self.decrease = decrease
            self.increase = increase
        }
    }

    /// Identifiers come from the caller because they are screen-scoped: the component cannot know
    /// which screen it is on, and two steppers sharing one identifier are indistinguishable to a
    /// UI test.
    public struct AccessibilityIdentifiers {
        let value: String
        let decrease: String
        let increase: String

        public init(value: String, decrease: String, increase: String) {
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
    private let accessibilityLabels: AccessibilityLabels
    private let accessibilityIdentifiers: AccessibilityIdentifiers
    private let onDecrease: () -> Void
    private let onIncrease: () -> Void

    public init(
        quantity: Int,
        bounds: ClosedRange<Int>,
        isDisabled: Bool = false,
        height: CGFloat = Primitives.Spacing.spacing40,
        cornerRadius: CGFloat = Sizing.radiusSoft,
        accessibilityLabels: AccessibilityLabels,
        accessibilityIdentifiers: AccessibilityIdentifiers,
        onDecrease: @escaping () -> Void,
        onIncrease: @escaping () -> Void
    ) {
        self.quantity = quantity
        self.bounds = bounds
        self.isDisabled = isDisabled
        self.height = height
        self.cornerRadius = cornerRadius
        self.accessibilityLabels = accessibilityLabels
        self.accessibilityIdentifiers = accessibilityIdentifiers
        self.onDecrease = onDecrease
        self.onIncrease = onIncrease
    }

    public var body: some View {
        HStack(spacing: Primitives.Spacing.spacing0) {
            stepButton(
                icon: .minus,
                label: accessibilityLabels.decrease,
                identifier: accessibilityIdentifiers.decrease,
                isEnabled: quantity > bounds.lowerBound,
                action: onDecrease
            )

            Text.build(theme.font.body.medium(String(quantity)))
                .foregroundStyle(contentColor(isEnabled: true))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .accessibilityLabel(accessibilityLabels.value)
                .accessibilityIdentifier(accessibilityIdentifiers.value)

            stepButton(
                icon: .plus,
                label: accessibilityLabels.increase,
                identifier: accessibilityIdentifiers.increase,
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
        label: String,
        identifier: String,
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
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }

    private func contentColor(isEnabled: Bool) -> Color {
        isDisabled || !isEnabled
            ? Theme.buttonPrimaryContentPrimaryDisabled
            : Theme.buttonPrimaryContentPrimaryDefault
    }
}

// MARK: - Previews

#if DEBUG
private extension QuantityStepper.AccessibilityIdentifiers {
    static let preview = Self(
        value: "preview.quantity.value.label",
        decrease: "preview.quantity.decrease.button",
        increase: "preview.quantity.increase.button"
    )
}

#Preview("Quantity stepper") {
    VStack(spacing: Primitives.Spacing.spacing16) {
        QuantityStepper(
            quantity: 1,
            bounds: 0...100,
            accessibilityLabels: .init(value: "Quantity: 1", decrease: "Remove", increase: "Increase"),
            accessibilityIdentifiers: .preview
        ) {} onIncrease: {}

        QuantityStepper(
            quantity: 100,
            bounds: 0...100,
            accessibilityLabels: .init(value: "Quantity: 100", decrease: "Decrease", increase: "Increase"),
            accessibilityIdentifiers: .preview
        ) {} onIncrease: {}

        QuantityStepper(
            quantity: 3,
            bounds: 0...100,
            isDisabled: true,
            accessibilityLabels: .init(value: "Quantity: 3", decrease: "Decrease", increase: "Increase"),
            accessibilityIdentifiers: .preview
        ) {} onIncrease: {}
    }
    .padding()
}
#endif
