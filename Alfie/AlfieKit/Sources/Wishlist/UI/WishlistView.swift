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
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: Primitives.Spacing.spacing16, alignment: .top),
                    count: 2
                ),
                spacing: Primitives.Spacing.spacing16
            ) {
                ForEach(viewModel.products) { product in
                    Button(
                        action: { viewModel.didTapProduct(product) },
                        label: {
                            VerticalProductCard(
                                viewModel: viewModel.productCardViewModel(for: product)
                            ) { _, type in
                                handleUserAction(forProduct: product, actionType: type)
                            }
                        }
                    )
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                }
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
        .padding(.vertical, Primitives.Spacing.spacing16)
        .toolbarView(hasDivider: viewModel.hasNavigationSeparator) {
            viewModel.didTapMyAccount()
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

// MARK: - Private Methods

private extension WishlistView {
    func handleUserAction(forProduct product: SelectedProduct, actionType: VerticalProductCard.ProductUserActionType) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch actionType {
        case .remove:
            viewModel.didSelectDelete(for: product)
        case .addToBag:
            viewModel.didTapAddToBag(for: product)
        case .wishlist:
            return
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
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
