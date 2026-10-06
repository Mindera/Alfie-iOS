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
            .toolbarView(hasDivider: viewModel.hasNavigationSeparator)
            .onAppear {
                viewModel.viewDidAppear()
            }
    }
}

// MARK: - Private Methods

private extension WishlistView {
    @ViewBuilder var content: some View {
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
                .accessibilityIdentifier(AccessibilityID.Wishlist.emptyState)
            } else {
                grid(of: products)
            }
        }
    }

    func grid(of products: [SelectedProduct]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: theme.spacing.space100, alignment: .top),
                    count: Constants.columns
                ),
                spacing: theme.spacing.space200
            ) {
                ForEach(products) { product in
                    Button(
                        action: { viewModel.didTapProduct(product) },
                        label: { productCard(for: product) }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(AccessibilityID.Wishlist.item(id: product.id))
                }
            }
            .padding(theme.spacing.space200)
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
#Preview {
    WishlistView(
        viewModel: WishlistViewModel(
            hasNavigationSeparator: true,
            dependencies: WishlistDependencyContainer(
                wishlistService: MockWishlistService(),
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
            )
        ) { _ in }
    )
}
#endif
