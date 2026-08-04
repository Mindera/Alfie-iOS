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
            // Non-editable entry point: a Button (VoiceOver-operable) wrapping a display-only search
            // bar; the tap presents the full search flow.
            Button {
                didTapSearch()
            } label: {
                ThemedSearchBarView(
                    searchText: .constant(""),
                    placeholder: L10n.Home.SearchBar.placeholder,
                    theme: .soft,
                    dismissConfiguration: .init(type: .hidden)
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.Shop.searchInput)
            .accessibilityLabel(L10n.Home.SearchBar.placeholder)
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
