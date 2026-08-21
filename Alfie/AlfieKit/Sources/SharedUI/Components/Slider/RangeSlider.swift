import SwiftUI

// MARK: - RangeSliderConfiguration

public struct RangeSliderConfiguration {
    public let bounds: ClosedRange<Double>
    public let step: Double
    @Binding public var lowerValue: Double
    @Binding public var upperValue: Double
    /// Announced by VoiceOver for each thumb, e.g. `{ "£\(Int($0))" }`.
    public let valueDescription: (Double) -> String
    public let lowerLabel: String
    public let upperLabel: String

    public init(
        bounds: ClosedRange<Double>,
        step: Double = 1,
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        lowerLabel: String,
        upperLabel: String,
        valueDescription: @escaping (Double) -> String
    ) {
        self.bounds = bounds
        self.step = step
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
        self.valueDescription = valueDescription
    }
}

// MARK: - RangeSlider

/// Two-thumb range selector. SwiftUI's `Slider` is single-value only, so this is bespoke.
/// Domain-agnostic over `Double` — currency formatting is the caller's job via `valueDescription`.
public struct RangeSlider: View {
    private let configuration: RangeSliderConfiguration
    /// Which thumb the active drag captured. Held for the whole gesture so a thumb dragged
    /// past its sibling keeps following the finger instead of handing over mid-drag.
    @State private var activeThumb: Thumb?

    private enum Thumb { case lower, upper }

    public init(configuration: RangeSliderConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = max(geometry.size.width - Constants.thumbDiameter, 1)

            ZStack(alignment: .leading) {
                track
                activeTrack(width: width)
                thumb(for: .lower, width: width)
                thumb(for: .upper, width: width)
            }
            .frame(height: Constants.trackHitHeight)
            .contentShape(Rectangle())
            .gesture(dragGesture(width: width))
        }
        .frame(height: Constants.trackHitHeight)
    }

    // MARK: - Subviews

    private var track: some View {
        Capsule()
            .fill(Theme.borderSoft)
            .frame(height: Constants.trackHeight)
    }

    private func activeTrack(width: CGFloat) -> some View {
        Capsule()
            .fill(Theme.contentContentPrimary)
            .frame(width: max(offset(for: upperFraction, width: width) - offset(for: lowerFraction, width: width), 0),
                   height: Constants.trackHeight)
            .offset(x: offset(for: lowerFraction, width: width) + Constants.thumbRadius)
    }

    private func thumb(for thumb: Thumb, width: CGFloat) -> some View {
        let value = thumb == .lower ? configuration.lowerValue : configuration.upperValue
        let fraction = thumb == .lower ? lowerFraction : upperFraction

        return Circle()
            .fill(Theme.surfaceBackgroundPrimary)
            .overlay(Circle().strokeBorder(Theme.contentContentPrimary, lineWidth: Constants.thumbBorder))
            .shadow(color: Constants.shadowColour, radius: Constants.shadowRadius, y: Constants.shadowOffsetY)
            .frame(width: Constants.thumbDiameter, height: Constants.thumbDiameter)
            .offset(x: offset(for: fraction, width: width))
            .accessibilityElement()
            .accessibilityLabel(thumb == .lower ? configuration.lowerLabel : configuration.upperLabel)
            .accessibilityValue(configuration.valueDescription(value))
            .accessibilityAdjustableAction { direction in
                adjust(thumb, by: direction == .increment ? configuration.step : -configuration.step)
            }
    }

    // MARK: - Geometry

    private var lowerFraction: Double { fraction(of: configuration.lowerValue) }
    private var upperFraction: Double { fraction(of: configuration.upperValue) }

    private func fraction(of value: Double) -> Double {
        let span = configuration.bounds.upperBound - configuration.bounds.lowerBound
        guard span > 0 else { return 0 }
        return ((value - configuration.bounds.lowerBound) / span).clamped(to: 0...1)
    }

    private func offset(for fraction: Double, width: CGFloat) -> CGFloat {
        width * fraction
    }

    // MARK: - Interaction

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                let fraction = ((gesture.location.x - Constants.thumbRadius) / width).clamped(to: 0...1)
                let thumb = activeThumb ?? nearestThumb(to: fraction)
                activeThumb = thumb
                set(thumb, toFraction: fraction)
            }
            .onEnded { _ in activeThumb = nil }
    }

    /// Ties go to the lower thumb only when the touch is left of it; otherwise the upper thumb
    /// wins, so a range collapsed at one point can still be pulled open in both directions.
    private func nearestThumb(to fraction: Double) -> Thumb {
        let lowerDistance = abs(fraction - lowerFraction)
        let upperDistance = abs(fraction - upperFraction)
        if lowerDistance == upperDistance {
            return fraction < lowerFraction ? .lower : .upper
        }
        return lowerDistance < upperDistance ? .lower : .upper
    }

    private func set(_ thumb: Thumb, toFraction fraction: Double) {
        let span = configuration.bounds.upperBound - configuration.bounds.lowerBound
        let raw = configuration.bounds.lowerBound + span * fraction
        let stepped = stepped(raw)

        switch thumb {
        case .lower:
            configuration.lowerValue = min(stepped, configuration.upperValue)
        case .upper:
            configuration.upperValue = max(stepped, configuration.lowerValue)
        }
    }

    private func adjust(_ thumb: Thumb, by delta: Double) {
        switch thumb {
        case .lower:
            configuration.lowerValue = stepped(configuration.lowerValue + delta)
                .clamped(to: configuration.bounds.lowerBound...configuration.upperValue)
        case .upper:
            configuration.upperValue = stepped(configuration.upperValue + delta)
                .clamped(to: configuration.lowerValue...configuration.bounds.upperBound)
        }
    }

    private func stepped(_ value: Double) -> Double {
        guard configuration.step > 0 else { return value }
        let steps = (value / configuration.step).rounded()
        return (steps * configuration.step).clamped(to: configuration.bounds)
    }

    // MARK: - Constants

    private enum Constants {
        static let trackHeight: CGFloat = 2
        static let trackHitHeight: CGFloat = 24
        static let thumbDiameter: CGFloat = 24
        static let thumbRadius: CGFloat = thumbDiameter / 2
        static let thumbBorder: CGFloat = 1
        // Figma "Shadow-Sheer": 0px 1px 2px rgba(0,0,0,0.05). No shadow token exists yet.
        static let shadowColour = Color.black.opacity(0.05)
        static let shadowRadius: CGFloat = 1
        static let shadowOffsetY: CGFloat = 1
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    struct Harness: View {
        @State private var lower: Double = 40
        @State private var upper: Double = 120

        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("£\(Int(lower)) – £\(Int(upper))")
                RangeSlider(
                    configuration: .init(
                        bounds: 0...480,
                        lowerValue: $lower,
                        upperValue: $upper,
                        lowerLabel: "Minimum price",
                        upperLabel: "Maximum price",
                        valueDescription: { "£\(Int($0))" }
                    )
                )
            }
            .padding(24)
        }
    }
    return Harness()
}
