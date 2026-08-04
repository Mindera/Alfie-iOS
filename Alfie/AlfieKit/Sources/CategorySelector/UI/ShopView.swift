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
            ThemedSearchBarView(
                searchText: .constant(""),
                placeholder: L10n.Home.SearchBar.placeholder,
                theme: .soft,
                dismissConfiguration: .init(type: .back, accessibilityId: AccessibilityID.Shop.searchBackButton),
                inputAccessibilityId: AccessibilityID.Shop.searchInput
            )
            // Non-editable entry point; the tap presents the full search flow (matches Home).
            .disabled(true)
            .onTapGesture { didTapSearch() }
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
