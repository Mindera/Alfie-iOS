import AccessibilityIdentifiers
import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct ShopView<CategoriesViewModel: CategoriesViewModelProtocol>: View {
    @ViewBuilder private let categoriesView: CategoriesView<CategoriesViewModel>
    private let didTapSearch: () -> Void

    init(
        categoriesViewModel: CategoriesViewModel,
        didTapSearch: @escaping () -> Void
    ) {
        self.categoriesView = CategoriesView(viewModel: categoriesViewModel)
        self.didTapSearch = didTapSearch
    }

    var body: some View {
        VStack(spacing: theme.spacing.space0) {
            SearchBarEntryButton(
                placeholder: L10n.Home.SearchBar.placeholder,
                accessibilityIdentifier: AccessibilityID.Shop.searchInput,
                action: didTapSearch
            )
            .padding(.horizontal, theme.spacing.space200)
            .padding(.top, theme.spacing.space100)
            .padding(.bottom, theme.spacing.space200)

            categoriesView
        }
    }
}

// MARK: Preview

#if DEBUG
#Preview {
    ShopView(
        categoriesViewModel: MockCategoriesViewModel(
            state: .success(.init(categories: [])),
            categories: NavigationItem.fixtures
        )
    ) {}
}
#endif
