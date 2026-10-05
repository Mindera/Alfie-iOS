import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BagView<ViewModel: BagViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @State private var removalSnackbarConfiguration: SnackbarViewConfiguration?

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .toolbarView()
            .onAppear {
                viewModel.viewDidAppear()
            }
            // A failed removal is transient and never leaves the bag. Dismissing the Snackbar
            // clears the outcome so an identical later one re-presents cleanly.
            .onChange(of: viewModel.removalFailure) { failure in
                guard let failure else {
                    removalSnackbarConfiguration = nil
                    return
                }
                removalSnackbarConfiguration = .init(
                    type: .error,
                    text: Self.errorMessage(for: failure),
                    showCloseButton: true,
                    icon: Icon.warning.image,
                    onDismiss: { viewModel.didDismissRemovalFailure() }
                )
            }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            BagLoadingView()

        case .success(let cart):
            // A shopper with no cart and a cart with nothing left in it are the same empty bag.
            if let cart, !cart.lines.isEmpty {
                VStack(spacing: 0) {
                    // The Snackbar belongs to the list, so it rises above the summary, not over it.
                    BagLineList(
                        lines: cart.lines,
                        onSelect: viewModel.didSelectLine,
                        onDelete: viewModel.didSelectDelete
                    )
                    .snackbarView(configuration: $removalSnackbarConfiguration)
                    BagPurchaseSummary(total: cart.grandTotal.amountFormattedOrUnavailable)
                }
                // The Snackbar goes with the list, so a failure cannot outlive it and re-present later.
                .onDisappear {
                    removalSnackbarConfiguration = nil
                    viewModel.didDismissRemovalFailure()
                }
            } else {
                BagEmptyView()
            }

        case .error(let error):
            ErrorView(
                title: L10n.Bag.ErrorView.title,
                message: Self.errorMessage(for: error.type),
                buttons: [
                    .init(
                        cta: L10n.Bag.ErrorView.Retry.cta,
                        accessibilityId: AccessibilityID.Bag.errorRetryButton,
                        action: viewModel.didTapRetry
                    ),
                ]
            )
            .accessibilityIdentifier(AccessibilityID.Bag.errorView)
        }
    }

    /// The title is the same for every error, so only the message varies. Switched exhaustively
    /// rather than with a `default`, so a new `BFFRequestErrorType` has to come here and choose its
    /// copy instead of silently inheriting the generic message.
    ///
    /// Shared with the removal-failure Snackbar, so a failed read and a failed write tell the
    /// shopper the same thing about the same cause.
    static func errorMessage(for type: BFFRequestError.BFFRequestErrorType) -> String {
        switch type {
        case .noInternet:
            return L10n.Bag.ErrorView.NoInternet.message

        // A read recovers from `.cart(.cartNotFound)` before it reaches here, so this is the
        // removal path: the shopper swiped a row on a cart the server has since forgotten. The
        // generic message fits — the next read shows them the empty bag.
        case .generic, .emptyResponse, .product, .cart, .rateLimited, .timeout, .serverError:
            return L10n.Bag.ErrorView.Generic.message
        }
    }
}

private struct BagLineList: View {
    let lines: [CartLine]
    let onSelect: (CartLine) -> Void
    let onDelete: (CartLine) -> Void

    var body: some View {
        List {
            ForEach(lines) { line in
                // The divider sits outside the row's `Button`, so it is not part of the tap target.
                VStack(spacing: Constants.lineSpacing) {
                    BagLineRow(line: line) { onSelect(line) }
                    if line.id != lines.last?.id {
                        BagDivider()
                            .padding(.horizontal, Sizing.spacingSpacingMd)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // A `Button` rather than `.onDelete` so it can carry an accessibility
                    // identifier, and no full swipe: the removal is a server write, so it takes
                    // a deliberate tap on Remove rather than firing off the end of a gesture.
                    Button(role: .destructive) {
                        onDelete(line)
                    } label: {
                        Label {
                            Text(L10n.Bag.Remove.cta)
                        } icon: {
                            Icon.close.image
                        }
                    }
                    .tint(Theme.surfaceBackgroundDestructive)
                    .accessibilityIdentifier(AccessibilityID.Bag.lineItemRemoveButton(id: line.id))
                }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(Constants.lineSpacing)
        .padding(.top, Sizing.spacingSpacingMd)
        .accessibilityIdentifier(AccessibilityID.Bag.bagView)
    }
}

private struct BagEmptyView: View {
    var body: some View {
        VStack(spacing: Sizing.spacingSpacingMd) {
            ThemedIcon(.bag, tint: Theme.contentContentPrimary)
            Text.build(theme.font.body.medium(L10n.Bag.Empty.title))
                .foregroundStyle(Theme.contentContentPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Sizing.spacingSpacingMd)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.Bag.emptyState)
    }
}

/// Skeleton rows rather than a spinner, so the wait is shaped like the bag that follows it.
/// The shimmer is applied per row: it hides what it covers and overlays a single rectangle, so
/// wrapping the stack instead would wash the whole screen grey.
private struct BagLoadingView: View {
    var body: some View {
        VStack(spacing: Constants.skeletonRowSpacing) {
            ForEach(0 ..< Constants.skeletonRowCount, id: \.self) { _ in
                Color.clear
                    .frame(height: BagLineRow.minHeight)
                    .shimmering(while: .constant(true), cornerRadius: Sizing.radiusSoft)
            }
            Spacer()
        }
        .padding(Sizing.spacingSpacingMd)
        // The skeleton is decorative. VoiceOver gets one element announcing the fetch rather than
        // four unlabelled shapes it would otherwise read as blank.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.Loading.title)
    }
}

private enum Constants {
    static let skeletonRowCount = 4
    static let lineSpacing = Sizing.spacingSpacingXs
    static let skeletonRowSpacing = lineSpacing * 2 + Sizing.borderBorderWeightDefault
}

#if DEBUG
#Preview("Success") {
    BagView(viewModel: MockBagViewModel(state: .success(.fixture(lines: [.fixture()]))))
}

#Preview("Empty") {
    BagView(viewModel: MockBagViewModel(state: .success(nil)))
}

#Preview("Loading") {
    BagView(viewModel: MockBagViewModel(state: .loading))
}

#Preview("Error") {
    BagView(viewModel: MockBagViewModel(state: .error(.init(type: .generic))))
}
#endif
