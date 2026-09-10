import SwiftUI

/// A non-editable search entry point: a VoiceOver-operable `Button` wrapping a display-only
/// `ThemedSearchBarView` (`.soft`). Tapping runs `action` — typically presenting the full search
/// flow. Shared by the Home and Shop headers so the button/accessibility wrapping lives in one place.
///
/// The inner bar is `.allowsHitTesting(false)` + `.accessibilityHidden(true)`, so the `Button` is the
/// single accessible element (its label/id come from the parameters). Callers own outer layout
/// (padding, `matchedGeometryEffect`, …).
///
/// A `scan` configuration adds a second control alongside the bar, opening the tag scanner. It is a
/// sibling of the bar rather than an icon inside it, so it is its own accessible element and the
/// bar's own trailing icon slot stays free for the magnifying glass.
public struct SearchBarEntryButton: View {
    /// The Scan control's identity and action. Absent on a search bar that has no scanner behind it.
    public struct ScanConfiguration {
        let accessibilityIdentifier: String
        let action: () -> Void

        public init(accessibilityIdentifier: String, action: @escaping () -> Void) {
            self.accessibilityIdentifier = accessibilityIdentifier
            self.action = action
        }
    }

    private let placeholder: String
    private let accessibilityIdentifier: String
    private let scan: ScanConfiguration?
    private let action: () -> Void

    public init(
        placeholder: String,
        accessibilityIdentifier: String,
        scan: ScanConfiguration? = nil,
        action: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.accessibilityIdentifier = accessibilityIdentifier
        self.scan = scan
        self.action = action
    }

    public var body: some View {
        HStack(spacing: theme.spacing.space150) {
            searchButton

            if let scan {
                scanButton(scan)
            }
        }
    }

    private var searchButton: some View {
        Button(action: action) {
            ThemedSearchBarView(
                searchText: .constant(""),
                placeholder: placeholder,
                theme: .soft,
                dismissConfiguration: .init(type: .hidden)
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(placeholder)
    }

    private func scanButton(_ scan: ScanConfiguration) -> some View {
        Button(action: scan.action) {
            ThemedIcon(.scan, size: .medium, tint: Primitives.Colours.neutrals800)
                .frame(width: Constants.scanTapTarget, height: Constants.scanTapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(scan.accessibilityIdentifier)
        .accessibilityLabel(L10n.Search.ScanButton.accessibilityLabel)
    }

    private enum Constants {
        /// The glyph is icon-sized; the tap target is not, so the control still meets the HIG
        /// minimum next to a 32pt search bar.
        static let scanTapTarget: CGFloat = 44
    }
}
