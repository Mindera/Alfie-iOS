import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct WishListView<ViewModel: WishListViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top),
                    count: 2
                ),
                spacing: Spacing.space200
            ) {
                ForEach(viewModel.products) { product in
                    VerticalProductCard(
                        viewModel: .init(
                            configuration: .init(size: .medium, hideDetails: false, actionType: .remove),
                            product: product,
                            colorTitle: LocalizableGeneral.$color + ":",
                            sizeTitle: LocalizableGeneral.$size + ":",
                            oneSizeTitle: LocalizableGeneral.$oneSize,
                            addToBagTitle: LocalizableGeneral.$addToBag,
                            outOfStockTitle: LocalizableGeneral.$outOfStock,
                            isAddToBagDisabled: product.defaultVariant.stock == .zero
                        )
                    ) { _, type in
                        handleUserAction(forProduct: product, actionType: type)
                    }
                }
            }
            .padding(.horizontal, Spacing.space200)
        }
        .padding(.vertical, Spacing.space200)
        .withToolbar(for: .wishlist, viewModel: viewModel.toolbarModifierViewModel)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

// MARK: - Private Methods

private extension WishListView {
    func handleUserAction(forProduct product: Product, actionType: VerticalProductCard.ProductUserActionType) {
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

#Preview {
    WishListView(
        viewModel: WishListViewModel(
            dependencies: WishListDependencyContainer(
                wishListService: MockWishListService(),
                bagService: MockBagService(),
                configurationService: MockConfigurationService()
            )
        )
    )
        .environmentObject(Coordinator())
}
