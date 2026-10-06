import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct WishlistView<ViewModel: WishlistViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        content
            .snackbarView(configuration: removalSnackbar)
            .toolbarView(hasDivider: viewModel.hasNavigationSeparator)
            .onAppear {
                viewModel.viewDidAppear()
            }
            .onDisappear {
                viewModel.didDismissRemovalSnackbar()
            }
    }

    private var removalSnackbar: Binding<SnackbarViewConfiguration?> {
        Binding(
            get: {
                viewModel.undoableRemoval.map { removal in
                    SnackbarViewConfiguration(
                        id: removal.id,
                        text: L10n.Wishlist.Removed.message,
                        icon: nil,
                        actionButtonLabel: L10n.Wishlist.Removed.Undo.cta,
                        onActionTap: viewModel.didTapUndoRemoval
                    )
                }
            },
            set: { configuration in
                if configuration == nil {
                    viewModel.didDismissRemovalSnackbar()
                }
            }
        )
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            Color.clear

        case .success(let products):
            if products.isEmpty {
                EmptyStateView(
                    icon: .heart,
                    title: L10n.Wishlist.Empty.title,
                    message: L10n.Wishlist.Empty.message
                )
                .accessibilityLabel(L10n.Accessibility.wishlistEmpty)
                .accessibilityIdentifier(AccessibilityID.Wishlist.emptyState)
            } else {
                grid(of: products)
            }
        }
    }
}

// MARK: - Private Methods

private extension WishlistView {
    func grid(of products: [SelectedProduct]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: Sizing.spacingSpacingXs, alignment: .top),
                    count: Constants.columns
                ),
                spacing: Sizing.spacingSpacingMd
            ) {
                ForEach(products) { product in
                    productCard(for: product)
                        .onTapGesture {
                            viewModel.didTapProduct(product)
                        }
                        .accessibilityIdentifier(AccessibilityID.Wishlist.item(id: product.id))
                }
            }
            .padding(Sizing.spacingSpacingMd)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityID.Wishlist.grid)
        }
    }

    func productCard(for product: SelectedProduct) -> some View {
        VerticalProductCard(
            viewModel: .init(
                configuration: .init(size: .medium),
                selectedProduct: product,
                addToBagTitle: L10n.Product.AddToBag.Button.cta,
                outOfStockTitle: L10n.Product.OutOfStock.Button.cta
            ),
            onUserAction: { _, type in
                handleUserAction(forProduct: product, actionType: type)
            },
            isFavorite: true,
            actionAccessibilityIdentifier: AccessibilityID.Wishlist.removeButton(id: product.id),
            actionAccessibilityLabel: L10n.Accessibility.removeFromWishlist
        )
    }

    func handleUserAction(forProduct product: SelectedProduct, actionType: VerticalProductCard.ProductUserActionType) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch actionType {
        case .wishlist:
            viewModel.didSelectDelete(for: product)
        case .addToBag:
            viewModel.didTapAddToBag(for: product)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

private enum Constants {
    static let columns = 2
}

#if DEBUG
#Preview("Success") {
    WishlistView(viewModel: MockWishlistViewModel(state: .success([SelectedProduct(product: .fixture())])))
}

#Preview("Removed") {
    let removed = SelectedProduct(product: .fixture(id: "removed"))
    return WishlistView(
        viewModel: MockWishlistViewModel(
            state: .success([SelectedProduct(product: .fixture())]),
            undoableRemoval: WishlistRemoval(productId: removed.product.id, from: [removed])
        )
    )
}

#Preview("Empty") {
    WishlistView(viewModel: MockWishlistViewModel(state: .success([])))
}

#Preview("Loading") {
    WishlistView(viewModel: MockWishlistViewModel(state: .loading))
}
#endif
