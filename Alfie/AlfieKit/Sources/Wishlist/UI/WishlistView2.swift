import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct WishlistView2<ViewModel: WishlistViewModelProtocol2>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
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
        .toolbarView(hasDivider: viewModel.hasNavigationSeparator) {
            viewModel.didTapMyAccount()
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

// MARK: - Private Methods

private extension WishlistView2 {
    func handleUserAction(forProduct product: SelectionProduct, actionType: VerticalProductCard.ProductUserActionType) {
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

//#if DEBUG
//#Preview {
//    WishlistView2(
//        viewModel: WishlistViewModel(
//            dependencies: WishlistDependencyContainer(
//                wishlistService: MockWishlistService(),
//                bagService: MockBagService(),
//                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
//            )
//        )
//    )
//        .environmentObject(Coordinator())
//}
//#endif
