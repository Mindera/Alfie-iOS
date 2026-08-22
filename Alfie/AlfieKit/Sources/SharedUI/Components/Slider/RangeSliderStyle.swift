import SwiftUI
import Utils

/// Resolves a `RangeSlider`'s geometry, value arithmetic and colours. Extracted from the view so
/// the parts that can actually be wrong — stepping, clamping, the collapsed-range tie-break — are
/// unit-testable without a rendered slider or a snapshot.
struct RangeSliderStyle {
    enum Thumb: Equatable {
        case lower
        case upper
    }

    let bounds: ClosedRange<Double>
    let step: Double

    // MARK: - Effective values

    /// A nil bound means "no limit on that side" (ALFMOB-481). The thumb still has to sit
    /// somewhere, so it rests on the track end — which is also what the user would drag from.
    func effectiveValue(_ value: Double?, for thumb: Thumb) -> Double {
        switch thumb {
        case .lower:
            return value ?? bounds.lowerBound
        case .upper:
            return value ?? bounds.upperBound
        }
    }

    // MARK: - Geometry

    /// Position of `value` along the track as 0...1. Values typed beyond the category bounds are
    /// legitimate (the bounds are the category's range, not a limit on what may be filtered), so
    /// the thumb pins to the track end rather than the value being altered.
    func fraction(of value: Double) -> Double {
        let span = bounds.upperBound - bounds.lowerBound
        guard span > 0 else { return 0 }
        return ((value - bounds.lowerBound) / span).clamped(to: 0...1)
    }

    func value(atFraction fraction: Double) -> Double {
        let span = bounds.upperBound - bounds.lowerBound
        return bounds.lowerBound + span * fraction.clamped(to: 0...1)
    }

    func offset(forFraction fraction: Double, trackWidth: CGFloat) -> CGFloat {
        trackWidth * fraction
    }

    // MARK: - Stepping

    /// Snaps to the step grid *outwards* — the lower thumb floors, the upper ceils — so a stepped
    /// range never excludes a product sitting on the boundary. Same rule the min/max bounds are
    /// derived under (ALFMOB-481), so slider and fields cannot disagree.
    func stepped(_ value: Double, for thumb: Thumb) -> Double {
        guard step > 0 else { return value.clamped(to: bounds) }
        let steps = value / step
        let snapped = thumb == .lower ? steps.rounded(.down) : steps.rounded(.up)
        return (snapped * step).clamped(to: bounds)
    }

    // MARK: - Dragging

    /// Result of dragging `thumb` to `fraction`, clamped so the thumbs never cross. Typing is not
    /// routed through here — a typed min above the max must surface as an error, not be clamped
    /// away (ALFMOB-481).
    func draggedValue(
        for thumb: Thumb,
        toFraction fraction: Double,
        lower: Double?,
        upper: Double?
    ) -> Double {
        let raw = stepped(value(atFraction: fraction), for: thumb)
        switch thumb {
        case .lower:
            return min(raw, effectiveValue(upper, for: .upper))
        case .upper:
            return max(raw, effectiveValue(lower, for: .lower))
        }
    }

    /// Result of nudging `thumb` by `delta` (VoiceOver's adjustable action).
    func adjustedValue(
        for thumb: Thumb,
        by delta: Double,
        lower: Double?,
        upper: Double?
    ) -> Double {
        let lowerValue = effectiveValue(lower, for: .lower)
        let upperValue = effectiveValue(upper, for: .upper)
        switch thumb {
        case .lower:
            return stepped(lowerValue + delta, for: .lower)
                .clamped(to: bounds.lowerBound...max(bounds.lowerBound, upperValue))
        case .upper:
            return stepped(upperValue + delta, for: .upper)
                .clamped(to: min(lowerValue, bounds.upperBound)...bounds.upperBound)
        }
    }

    /// Which thumb a touch captures. Ties go to the lower thumb only when the touch is left of it;
    /// otherwise the upper wins, so a range collapsed to a point can be pulled open both ways.
    func nearestThumb(toFraction fraction: Double, lowerFraction: Double, upperFraction: Double) -> Thumb {
        let lowerDistance = abs(fraction - lowerFraction)
        let upperDistance = abs(fraction - upperFraction)
        if lowerDistance == upperDistance {
            return fraction < lowerFraction ? .lower : .upper
        }
        return lowerDistance < upperDistance ? .lower : .upper
    }

    // MARK: - Text field round-trip

    /// Whole-unit text for a field. A nil value renders empty — never `0`, which would read as a
    /// real bound (ALFMOB-481).
    func fieldText(for value: Double?) -> String {
        guard let value else { return "" }
        return String(Int(value.rounded()))
    }

    /// Parses typed text back to a value. Empty (or unparseable) clears the bound to nil. The
    /// result is snapped to the step grid but deliberately *not* clamped against the other thumb.
    func fieldValue(from text: String, for thumb: Thumb) -> Double? {
        let digits = text.filter(\.isNumber)
        guard let parsed = Double(digits) else { return nil }
        guard step > 0 else { return parsed }
        let steps = parsed / step
        let snapped = thumb == .lower ? steps.rounded(.down) : steps.rounded(.up)
        return snapped * step
    }

    // MARK: - Colours

    var trackColor: Color { Theme.borderSoft }
    var activeTrackColor: Color { Theme.contentContentPrimary }
    var thumbFillColor: Color { Theme.surfaceBackgroundPrimary }
    var thumbBorderColor: Color { Theme.contentContentPrimary }

    // MARK: - Dimensions

    static let trackHeight: CGFloat = 2
    static let trackHitHeight: CGFloat = 24
    static let thumbDiameter: CGFloat = 24
    static let thumbRadius: CGFloat = thumbDiameter / 2
    static let thumbBorderWidth: CGFloat = 1
    /// Apple HIG minimum tappable height. Applied as a transparent overlay, so it changes no
    /// rendered pixel of the 24pt row the design draws.
    static let touchTargetHeight: CGFloat = 44

    // Figma "Shadow-Sheer": 0px 1px 2px rgba(0,0,0,0.05). No shadow token exists yet — reported
    // on ALFMOB-479 rather than substituted with a near-neighbour.
    static let shadowColor = Color.black.opacity(0.05)
    static let shadowRadius: CGFloat = 1
    static let shadowOffsetY: CGFloat = 1
}
