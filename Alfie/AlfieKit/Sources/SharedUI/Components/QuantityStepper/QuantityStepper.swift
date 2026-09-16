import AccessibilityIdentifiers
import SwiftUI

// MARK: - QuantityStepper

/// A `− n +` control, sized and coloured to stand in for the `ThemedButton` it replaces.
///
/// It reports intent and renders what it is given: the quantity is a value, not state it owns, so a
/// caller writing to a server shows the server's answer rather than a number this drifted to on its
/// own. Both bounds come from the caller for the same reason — what the lower one *means* differs
/// by screen. Passing `0` lets the last decrement be a removal.
public struct QuantityStepper: View {
    /// Spoken labels. The component carries none of its own: "Remove from bag" is the right words
    /// for the PDP and the wrong ones for a screen that steps a number with no bag behind it.
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

    private enum Constants {
        static let iconSize: CGFloat = Sizing.iconsIconSmall
        /// Apple's minimum tap target. The control is 40pt tall — the `ThemedButton` height it
        /// stands in for — so the buttons claim their width here instead.
        static let minTapTarget: CGFloat = 44
    }

    private let quantity: Int
    private let bounds: ClosedRange<Int>
    private let isDisabled: Bool
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let accessibilityLabels: AccessibilityLabels
    private let onDecrease: () -> Void
    private let onIncrease: () -> Void

    public init(
        quantity: Int,
        bounds: ClosedRange<Int>,
        isDisabled: Bool = false,
        height: CGFloat = Primitives.Spacing.spacing40,
        cornerRadius: CGFloat = Sizing.radiusSoft,
        accessibilityLabels: AccessibilityLabels,
        onDecrease: @escaping () -> Void,
        onIncrease: @escaping () -> Void
    ) {
        self.quantity = quantity
        self.bounds = bounds
        self.isDisabled = isDisabled
        self.height = height
        self.cornerRadius = cornerRadius
        self.accessibilityLabels = accessibilityLabels
        self.onDecrease = onDecrease
        self.onIncrease = onIncrease
    }

    public var body: some View {
        HStack(spacing: Primitives.Spacing.spacing0) {
            stepButton(
                icon: .minus,
                label: accessibilityLabels.decrease,
                identifier: AccessibilityID.QuantityStepper.decreaseButton,
                isEnabled: quantity > bounds.lowerBound,
                action: onDecrease
            )

            Text.build(theme.font.body.medium(String(quantity)))
                .foregroundStyle(contentColor(isEnabled: true))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(AccessibilityID.QuantityStepper.value)

            stepButton(
                icon: .plus,
                label: accessibilityLabels.increase,
                identifier: AccessibilityID.QuantityStepper.increaseButton,
                isEnabled: quantity < bounds.upperBound,
                action: onIncrease
            )
        }
        .frame(height: height)
        .background(Theme.buttonPrimaryBackgroundPrimaryDefault)
        .cornerRadius(cornerRadius)
        // The quantity is read from the buttons' container, so VoiceOver announces the number once
        // rather than as an unlabelled element between two buttons.
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabels.value)
        .accessibilityIdentifier(AccessibilityID.QuantityStepper.control)
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
                // Colour alone is the only signal a step is unavailable, so the tap target stays
                // the same size whether or not it can be used.
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

#Preview("Quantity stepper") {
    VStack(spacing: 16) {
        QuantityStepper(
            quantity: 1,
            bounds: 0...100,
            accessibilityLabels: .init(value: "Quantity: 1", decrease: "Remove", increase: "Increase")
        ) {} onIncrease: {}

        QuantityStepper(
            quantity: 100,
            bounds: 0...100,
            accessibilityLabels: .init(value: "Quantity: 100", decrease: "Decrease", increase: "Increase")
        ) {} onIncrease: {}

        QuantityStepper(
            quantity: 3,
            bounds: 0...100,
            isDisabled: true,
            accessibilityLabels: .init(value: "Quantity: 3", decrease: "Decrease", increase: "Increase")
        ) {} onIncrease: {}
    }
    .padding()
}
