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
            .toolbarView(
                isWishlistEnabled: viewModel.isWishlistEnabled,
                openWishlistAction: viewModel.didTapWishlist,
                myAccountAction: viewModel.didTapMyAccount
            )
            .onAppear {
                viewModel.viewDidAppear()
            }
            .snackbarView(configuration: $removalSnackbarConfiguration)
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
            loadingView

        case .success(let cart):
            // A shopper with no cart and a cart with nothing left in it are the same empty bag.
            if let cart, !cart.lines.isEmpty {
                bagView(cart)
            } else {
                emptyView
            }

        case .error(let error):
            errorView(error)
        }
    }

    // MARK: - Content

    private func bagView(_ cart: Cart) -> some View {
        List {
            ForEach(cart.lines) { line in
                BagLineRow(line: line)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, Primitives.Spacing.spacing16)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // Swipe is the only removal affordance this epic ships (Q27). A `Button`
                        // rather than `.onDelete` so it can carry an accessibility identifier, and
                        // no full swipe: the removal is a server write, so it takes a deliberate
                        // tap on Remove rather than firing off the end of a gesture.
                        Button(role: .destructive) {
                            viewModel.didSelectDelete(line)
                        } label: {
                            Text(L10n.Bag.Remove.cta)
                        }
                        .accessibilityIdentifier(AccessibilityID.Bag.lineItemRemoveButton(id: line.id))
                    }
            }
            totalsView(cart)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, Primitives.Spacing.spacing16)
        }
        .listStyle(.plain)
        .listRowSpacing(Primitives.Spacing.spacing16)
        .padding(.vertical, Primitives.Spacing.spacing16)
        .accessibilityIdentifier(AccessibilityID.Bag.bagView)
    }

    /// Subtotal and total, with no checkout CTA — the bag is a dead end by design this epic (Q32).
    private func totalsView(_ cart: Cart) -> some View {
        VStack(spacing: Primitives.Spacing.spacing8) {
            Divider()
                .padding(.bottom, Primitives.Spacing.spacing8)
            totalRow(
                title: L10n.Bag.Subtotal.title,
                amount: cart.subtotal.amountFormattedOrUnavailable,
                accessibilityId: AccessibilityID.Bag.subtotal
            )
            totalRow(
                title: L10n.Bag.Total.title,
                amount: cart.grandTotal.amountFormattedOrUnavailable,
                accessibilityId: AccessibilityID.Bag.grandTotal,
                isProminent: true
            )
        }
    }

    private func totalRow(
        title: String,
        amount: String,
        accessibilityId: String,
        isProminent: Bool = false
    ) -> some View {
        HStack {
            Text.build(isProminent ? theme.font.body.medium(title) : theme.font.body.small(title))
            Spacer()
            Text.build(isProminent ? theme.font.body.medium(amount) : theme.font.body.small(amount))
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityId)
    }

    // MARK: - Empty

    /// Nothing has gone wrong, so there is no retry — title and message only (Q28/Q34).
    private var emptyView: some View {
        ErrorView(
            icon: Icon.bag.image,
            title: L10n.Bag.Empty.title,
            message: L10n.Bag.Empty.message
        )
        .accessibilityIdentifier(AccessibilityID.Bag.emptyState)
    }

    // MARK: - Error

    private func errorView(_ error: BFFRequestError) -> some View {
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

        case .generic, .emptyResponse, .product, .rateLimited, .timeout, .serverError:
            return L10n.Bag.ErrorView.Generic.message
        }
    }

    // MARK: - Loading

    /// Skeleton rows rather than a spinner, so the wait is shaped like the bag that follows it.
    /// The shimmer is applied per row: it hides what it covers and overlays a single rectangle, so
    /// wrapping the stack instead would wash the whole screen grey.
    private var loadingView: some View {
        VStack(spacing: Primitives.Spacing.spacing16) {
            ForEach(0 ..< Constants.skeletonRowCount, id: \.self) { _ in
                Color.clear
                    .frame(height: Constants.skeletonRowHeight)
                    .shimmering(while: .constant(true), cornerRadius: Sizing.radiusSoft)
            }
            Spacer()
        }
        .padding(Primitives.Spacing.spacing16)
        // The skeleton is decorative. VoiceOver gets one element announcing the fetch rather than
        // four unlabelled shapes it would otherwise read as blank.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.Loading.title)
    }
}

private enum Constants {
    static let skeletonRowCount = 4
    static let skeletonRowHeight: CGFloat = 100
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
