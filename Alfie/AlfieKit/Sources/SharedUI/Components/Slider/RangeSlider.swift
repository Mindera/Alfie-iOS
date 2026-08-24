import SwiftUI
import Utils

// MARK: - RangeSliderConfiguration

public struct RangeSliderConfiguration {
    /// Mirrors Figma's `Show Inputs` property — the paired fields belong to the slider so that
    /// typing drives the thumbs and the binding lives in one place.
    public struct Inputs {
        public let prefix: String?
        public let isError: Bool
        public let lowerAccessibilityIdentifier: String?
        public let upperAccessibilityIdentifier: String?

        public init(
            prefix: String? = nil,
            isError: Bool = false,
            lowerAccessibilityIdentifier: String? = nil,
            upperAccessibilityIdentifier: String? = nil
        ) {
            self.prefix = prefix
            self.isError = isError
            self.lowerAccessibilityIdentifier = lowerAccessibilityIdentifier
            self.upperAccessibilityIdentifier = upperAccessibilityIdentifier
        }
    }

    public let bounds: ClosedRange<Double>
    public let step: Double
    /// `nil` means no limit on that side — the thumb rests on the track end and the field is empty.
    @Binding public var lowerValue: Double?
    @Binding public var upperValue: Double?
    public let lowerLabel: String
    public let upperLabel: String
    /// Announced by VoiceOver for each thumb, e.g. `{ "£\(Int($0))" }`.
    public let valueDescription: (Double) -> String
    /// Announced instead of `valueDescription` when that side is unbounded. Without these,
    /// VoiceOver reads the track endpoint the thumb happens to rest on, so "no maximum" is
    /// indistinguishable from a maximum deliberately set to the top of the range.
    public let lowerUnboundedDescription: String
    public let upperUnboundedDescription: String
    /// `nil` hides the paired fields.
    public let inputs: Inputs?

    public init(
        bounds: ClosedRange<Double>,
        step: Double = 1,
        lowerValue: Binding<Double?>,
        upperValue: Binding<Double?>,
        lowerLabel: String,
        upperLabel: String,
        valueDescription: @escaping (Double) -> String,
        lowerUnboundedDescription: String,
        upperUnboundedDescription: String,
        inputs: Inputs? = nil
    ) {
        self.lowerUnboundedDescription = lowerUnboundedDescription
        self.upperUnboundedDescription = upperUnboundedDescription
        self.bounds = bounds
        self.step = step
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
        self.valueDescription = valueDescription
        self.inputs = inputs
    }
}

// MARK: - RangeSlider

/// Two-thumb range selector with an optional pair of bound text fields. SwiftUI's `Slider` is
/// single-value only, so this is bespoke. Domain-agnostic over `Double` — currency formatting is
/// the caller's job via `valueDescription` and `Inputs.prefix`.
public struct RangeSlider: View {
    private let configuration: RangeSliderConfiguration
    /// Which thumb the active drag captured. Held for the whole gesture so a thumb dragged
    /// past its sibling keeps following the finger instead of handing over mid-drag.
    @State private var activeThumb: RangeSliderStyle.Thumb?

    public init(configuration: RangeSliderConfiguration) {
        self.configuration = configuration
    }

    private var style: RangeSliderStyle {
        RangeSliderStyle(bounds: configuration.bounds, step: configuration.step)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.space100) {
            slider
            if let inputs = configuration.inputs {
                fields(inputs)
            }
        }
    }

    // MARK: - Slider

    private var slider: some View {
        GeometryReader { geometry in
            let trackWidth = max(geometry.size.width - RangeSliderStyle.thumbDiameter, 1)

            ZStack(alignment: .leading) {
                track
                activeTrack(trackWidth: trackWidth)
                thumb(for: .lower, trackWidth: trackWidth)
                thumb(for: .upper, trackWidth: trackWidth)
            }
            .frame(height: RangeSliderStyle.trackHitHeight)
            // Transparent overlay only — lifts the 24pt drawn row to the HIG's 44pt target
            // without moving a rendered pixel.
            .overlay(
                Color.clear
                    .frame(height: RangeSliderStyle.touchTargetHeight)
                    .contentShape(Rectangle())
                    .gesture(dragGesture(trackWidth: trackWidth))
            )
        }
        .frame(height: RangeSliderStyle.trackHitHeight)
    }

    private var track: some View {
        Capsule()
            .fill(style.trackColor)
            .frame(height: RangeSliderStyle.trackHeight)
    }

    private func activeTrack(trackWidth: CGFloat) -> some View {
        let lowerOffset = style.offset(forFraction: fraction(for: .lower), trackWidth: trackWidth)
        let upperOffset = style.offset(forFraction: fraction(for: .upper), trackWidth: trackWidth)

        return Capsule()
            .fill(style.activeTrackColor)
            .frame(width: max(upperOffset - lowerOffset, 0), height: RangeSliderStyle.trackHeight)
            .offset(x: lowerOffset + RangeSliderStyle.thumbRadius)
    }

    private func thumb(for thumb: RangeSliderStyle.Thumb, trackWidth: CGFloat) -> some View {
        Circle()
            .fill(style.thumbFillColor)
            .overlay(
                Circle().strokeBorder(style.thumbBorderColor, lineWidth: RangeSliderStyle.thumbBorderWidth)
            )
            .shadow(
                color: RangeSliderStyle.shadowColor,
                radius: RangeSliderStyle.shadowRadius,
                y: RangeSliderStyle.shadowOffsetY
            )
            .frame(width: RangeSliderStyle.thumbDiameter, height: RangeSliderStyle.thumbDiameter)
            .offset(x: style.offset(forFraction: fraction(for: thumb), trackWidth: trackWidth))
            .accessibilityElement()
            .accessibilityLabel(label(for: thumb))
            .accessibilityValue(accessibilityValue(for: thumb))
            .accessibilityAdjustableAction { direction in
                adjust(thumb, by: direction == .increment ? configuration.step : -configuration.step)
            }
    }

    // MARK: - Fields

    private func fields(_ inputs: RangeSliderConfiguration.Inputs) -> some View {
        HStack(spacing: theme.spacing.space200) {
            field(for: .lower, inputs: inputs)
            field(for: .upper, inputs: inputs)
        }
    }

    private func field(for thumb: RangeSliderStyle.Thumb, inputs: RangeSliderConfiguration.Inputs) -> some View {
        TextInput(
            configuration: .init(
                text: textBinding(for: thumb),
                label: label(for: thumb),
                // The category bound is the placeholder; an empty field means that side is
                // unfiltered, so it must never pre-fill with a real-looking value.
                placeholder: style.fieldText(for: bound(for: thumb)),
                prefix: inputs.prefix,
                keyboardType: .numberPad,
                isError: inputs.isError,
                accessibilityIdentifier: thumb == .lower
                    ? inputs.lowerAccessibilityIdentifier
                    : inputs.upperAccessibilityIdentifier,
                // The prefix carries the unit and is hidden from VoiceOver visually, so fold it
                // into the label — otherwise the field announces an unqualified number while the
                // thumbs announce a currency amount.
                accessibilityLabel: [inputs.prefix, label(for: thumb)]
                    .compactMap { $0 }
                    .joined(separator: " ")
            )
        )
    }

    private func textBinding(for thumb: RangeSliderStyle.Thumb) -> Binding<String> {
        Binding(
            get: { style.fieldText(for: value(for: thumb)) },
            set: { text in set(thumb, to: style.fieldValue(from: text, for: thumb)) }
        )
    }

    // MARK: - Values

    private func value(for thumb: RangeSliderStyle.Thumb) -> Double? {
        thumb == .lower ? configuration.lowerValue : configuration.upperValue
    }

    private func set(_ thumb: RangeSliderStyle.Thumb, to value: Double?) {
        switch thumb {
        case .lower:
            configuration.lowerValue = value
        case .upper:
            configuration.upperValue = value
        }
    }

    private func effectiveValue(for thumb: RangeSliderStyle.Thumb) -> Double {
        style.effectiveValue(value(for: thumb), for: thumb)
    }

    private func fraction(for thumb: RangeSliderStyle.Thumb) -> Double {
        style.fraction(of: effectiveValue(for: thumb))
    }

    private func bound(for thumb: RangeSliderStyle.Thumb) -> Double {
        thumb == .lower ? configuration.bounds.lowerBound : configuration.bounds.upperBound
    }

    private func label(for thumb: RangeSliderStyle.Thumb) -> String {
        thumb == .lower ? configuration.lowerLabel : configuration.upperLabel
    }

    /// An unset side announces as unbounded rather than as the endpoint its thumb rests on.
    private func accessibilityValue(for thumb: RangeSliderStyle.Thumb) -> String {
        guard let value = value(for: thumb) else {
            return thumb == .lower
                ? configuration.lowerUnboundedDescription
                : configuration.upperUnboundedDescription
        }
        return configuration.valueDescription(value)
    }

    // MARK: - Interaction

    private func dragGesture(trackWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                let fraction = ((gesture.location.x - RangeSliderStyle.thumbRadius) / trackWidth)
                    .clamped(to: 0...1)
                let thumb = activeThumb ?? style.nearestThumb(
                    toFraction: fraction,
                    lowerFraction: self.fraction(for: .lower),
                    upperFraction: self.fraction(for: .upper)
                )
                activeThumb = thumb
                set(thumb, to: style.draggedValue(
                    for: thumb,
                    toFraction: fraction,
                    lower: configuration.lowerValue,
                    upper: configuration.upperValue
                ))
            }
            .onEnded { _ in activeThumb = nil }
    }

    private func adjust(_ thumb: RangeSliderStyle.Thumb, by delta: Double) {
        set(thumb, to: style.adjustedValue(
            for: thumb,
            by: delta,
            lower: configuration.lowerValue,
            upper: configuration.upperValue
        ))
    }
}

#Preview {
    struct Harness: View {
        @State private var lower: Double? = 40
        @State private var upper: Double?

        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("\(lower.map { "£\(Int($0))" } ?? "no min") – \(upper.map { "£\(Int($0))" } ?? "no max")")
                RangeSlider(
                    configuration: .init(
                        bounds: 8...480,
                        lowerValue: $lower,
                        upperValue: $upper,
                        lowerLabel: "Min",
                        upperLabel: "Max",
                        valueDescription: { "£\(Int($0))" },
                        lowerUnboundedDescription: "No minimum",
                        upperUnboundedDescription: "No maximum",
                        inputs: .init(prefix: "£")
                    )
                )
            }
            .padding(24)
        }
    }
    return Harness()
}
