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
                        viewModel: viewModel.productCardViewModel(for: product)
                    ) { _, type in
                        handleUserAction(forProduct: product, actionType: type)
                    }
                }
            }
            .padding(.horizontal, Spacing.space200)
        }
        .padding(.vertical, Spacing.space200)
        .withToolbar(for: .wishlist)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

// MARK: - Private Methods

private extension WishListView {
    func handleUserAction(forProduct product: SelectionProduct, actionType: VerticalProductCard.ProductUserActionType) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch actionType {
        case .remove:
            viewModel.didSelectDelete(for: product)
        case .addToBag:
            viewModel.didTapAddToBag(for: product)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#Preview {
    WishListView(
        viewModel: WishListViewModel(
            dependencies: WishListDependencyContainer(
                wishListService: MockWishListService(),
                bagService: MockBagService()
            )
        )
    )
        .environmentObject(Coordinator())
}
