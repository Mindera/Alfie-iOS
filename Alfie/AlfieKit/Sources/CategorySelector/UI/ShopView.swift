import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct ShopView<CategoriesViewModel: CategoriesViewModelProtocol>: View {
    private let isRoot: Bool
    private let isWishlistEnabled: Bool
    @ViewBuilder private let categoriesView: CategoriesView<CategoriesViewModel>
    private let navigate: (CategorySelectorRoute) -> Void

    init(
        isRoot: Bool,
        isWishlistEnabled: Bool,
        categoriesViewModel: CategoriesViewModel,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.isRoot = isRoot
        self.isWishlistEnabled = isWishlistEnabled
        self.categoriesView = CategoriesView(viewModel: categoriesViewModel)
        self.navigate = navigate
    }

    var body: some View {
        categoriesView
            .toolbarView(
                isRoot: isRoot,
                isWishlistEnabled: isWishlistEnabled,
                openWishlistAction: { navigate(.wishlist(.wishlist)) },
                myAccountAction: { navigate(.myAccount(.myAccount)) }
            )
    }
}

// MARK: Preview

#if DEBUG
#Preview {
    ShopView(
        isRoot: true,
        isWishlistEnabled: true,
        categoriesViewModel: MockCategoriesViewModel(
            state: .success(.init(categories: [])),
            categories: NavigationItem.fixtures
        )
    ) { _ in }
}
#endif
