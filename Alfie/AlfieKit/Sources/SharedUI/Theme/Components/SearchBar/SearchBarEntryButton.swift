import SwiftUI

/// A non-editable search entry point: a VoiceOver-operable `Button` wrapping a display-only
/// `ThemedSearchBarView` (`.soft`). Tapping runs `action` — typically presenting the full search
/// flow. Shared by the Home and Shop headers so the button/accessibility wrapping lives in one place.
///
/// The inner bar is `.allowsHitTesting(false)` + `.accessibilityHidden(true)`, so the `Button` is the
/// single accessible element (its label/id come from the parameters). Callers own outer layout
/// (padding, `matchedGeometryEffect`, …).
///
/// A `scan` configuration puts a second control inside the bar, at its trailing edge, opening the
/// tag scanner — the design's "Scan Barcode" search variant, where the magnifying glass leads and
/// the scan glyph trails. It stays its own accessible element, so VoiceOver still offers search and
/// scan separately.
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
        searchButton
            .overlay(alignment: .trailing) {
                if let scan {
                    scanTapTarget(scan)
                }
            }
    }

    private var searchButton: some View {
        Button(action: action) {
            ThemedSearchBarView(
                searchText: .constant(""),
                placeholder: placeholder,
                theme: Constants.barTheme,
                dismissConfiguration: .init(type: .hidden),
                trailingAccessory: scan.map { _ in AnyView(scanGlyph) }
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(placeholder)
    }

    /// Matches the bar's own magnifying glass, so the pair bracketing the text reads as one set.
    private var scanGlyph: some View {
        ThemedIcon(.scanBarcode, size: .small, tint: Theme.contentContentPrimary)
    }

    /// The tap target is an overlay rather than a `Button` handed to the bar: the bar is drawn
    /// inside the search `Button` with hit testing off, which a nested button would inherit. It is
    /// square on the bar's height, so it stays centred on the glyph instead of reaching further
    /// across the text than the icon it covers.
    private func scanTapTarget(_ scan: ScanConfiguration) -> some View {
        Button(action: scan.action) {
            Color.clear
                .frame(size: Constants.scanTapTargetSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(scan.accessibilityIdentifier)
        .accessibilityLabel(L10n.Accessibility.scan)
    }

    private enum Constants {
        static let barTheme: ThemedSearchBarView.Theme = .soft
        /// Taken from the bar rather than copied, so the square tracks the bar's height.
        static let scanTapTargetSize = barTheme.searchBarHeight
    }
}
