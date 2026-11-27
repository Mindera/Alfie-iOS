#if DEBUG
import Mocks
import Model
import SharedUI
import SwiftUI

// PROTOTYPE for #189, throwaway. Two variants of "a Cart re-read failed over a Bag on screen",
// switchable from the segmented control at the bottom. The rows stand in for `BagLineRow`.
struct BagRereadFailurePrototypeView: View {
    enum Variant: String, CaseIterable, Identifiable {
        case snackbar = "A · Snackbar"
        case banner = "B · Banner"

        var id: String { rawValue }
    }

    @State private var variant: Variant
    @State private var rereadFailed: Bool
    @State private var snackbarConfiguration: SnackbarViewConfiguration?

    init(variant: Variant = .snackbar, rereadFailed: Bool = false) {
        _variant = State(initialValue: variant)
        _rereadFailed = State(initialValue: rereadFailed)
        _snackbarConfiguration = State(
            initialValue: variant == .snackbar && rereadFailed ? Self.failureSnackbar(onDismiss: {}) : nil
        )
    }

    private let cart = Cart.fixture(
        lines: [
            .fixture(id: "line-1", name: "Relaxed linen shirt", quantity: 1),
            .fixture(id: "line-2", name: "Wide-leg cotton trousers", quantity: 2),
            .fixture(id: "line-3", name: "Leather crossbody bag", quantity: 1),
        ]
    )

    var body: some View {
        VStack(spacing: 0) {
            bag
            prototypeControls
        }
        .onChange(of: variant) { _ in
            present()
        }
        .onChange(of: rereadFailed) { _ in
            present()
        }
    }

    private var bag: some View {
        VStack(spacing: 0) {
            if variant == .banner, rereadFailed {
                RereadFailureBanner { rereadFailed = false }
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            List {
                ForEach(cart.lines) { line in
                    PrototypeLineRow(line: line)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            .padding(.top, theme.sizing.spacingSpacingMd)
            .snackbarView(configuration: $snackbarConfiguration)
            PrototypeSummary(total: cart.grandTotal?.amountFormatted ?? "—")
        }
        .animation(.spring(), value: rereadFailed)
    }

    private var prototypeControls: some View {
        VStack(spacing: theme.sizing.spacingSpacingXs) {
            Text("Prototype · re-read: \(rereadFailed ? "FAILED" : "ok") · Lines kept: \(cart.lines.count)")
                .font(.caption.monospaced())
            HStack {
                Button("Fail re-read") {
                    rereadFailed = false
                    DispatchQueue.main.async { rereadFailed = true }
                }
                Spacer()
                Button("Re-read ok") { rereadFailed = false }
            }
            .buttonStyle(.bordered)
            Picker("Variant", selection: $variant) {
                ForEach(Variant.allCases) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(theme.sizing.spacingSpacingXs)
        .background(Color.yellow.opacity(0.25))
    }

    private func present() {
        guard variant == .snackbar, rereadFailed else {
            snackbarConfiguration = nil
            return
        }
        snackbarConfiguration = Self.failureSnackbar { rereadFailed = false }
    }

    private static func failureSnackbar(onDismiss: @escaping () -> Void) -> SnackbarViewConfiguration {
        .init(
            type: .error,
            text: L10n.Bag.ErrorView.NoInternet.message,
            showCloseButton: true,
            icon: Icon.warning.image,
            onDismiss: onDismiss
        )
    }
}

private struct RereadFailureBanner: View {
    let onRetry: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: theme.sizing.spacingSpacingXs) {
            Icon.warning.image
                .renderingMode(.template)
            VStack(alignment: .leading, spacing: 0) {
                Text.build(theme.font.body.mediumBold("Couldn't update your bag"))
                Text.build(theme.font.body.small(L10n.Bag.ErrorView.NoInternet.message))
            }
            Spacer(minLength: 0)
            ThemedButton(text: L10n.Bag.ErrorView.Retry.cta, type: .small, action: onRetry)
        }
        .foregroundStyle(theme.color.contentContentPrimary)
        .padding(theme.sizing.spacingSpacingXs)
        .background(theme.color.surfaceForegroundPrimary)
    }
}

private struct PrototypeLineRow: View {
    let line: CartLine

    var body: some View {
        HStack(alignment: .top, spacing: theme.sizing.spacingSpacingXs) {
            theme.color.surfaceForegroundPrimary
                .frame(width: 114, height: 152)
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
                Text.build(theme.font.body.medium(line.name ?? ""))
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline) {
                    Text.build(theme.font.body.medium(L10n.Bag.Quantity.label(line.quantity)))
                    Spacer(minLength: 0)
                    Text.build(theme.font.body.mediumBold(line.lineTotal?.amountFormatted ?? "—"))
                }
            }
            .padding(.vertical, theme.sizing.spacingSpacing2xs)
        }
        .foregroundStyle(theme.color.contentContentPrimary)
        .frame(minHeight: 152)
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
        .padding(.bottom, theme.sizing.spacingSpacingXs)
    }
}

private struct PrototypeSummary: View {
    let total: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
            HStack(alignment: .firstTextBaseline) {
                Text.build(theme.font.body.mediumBold(L10n.Bag.Total.title))
                Spacer(minLength: 0)
                Text.build(theme.font.body.mediumBold(total))
            }
            ThemedButton(text: L10n.Bag.Continue.cta, isFullWidth: true) {}
        }
        .foregroundStyle(theme.color.contentContentPrimary)
        .padding(.vertical, theme.sizing.spacingSpacingXs)
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
        .background(theme.color.surfaceBackgroundPrimary)
    }
}
#endif
