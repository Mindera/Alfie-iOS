import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct SearchView<ViewModel: SearchViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    private let autoFocus: Bool
    private let transition: SearchBarTransition?

    public init(viewModel: ViewModel, autoFocus: Bool = true, transition: SearchBarTransition? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.autoFocus = autoFocus
        self.transition = transition
    }

    public var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            ThemedDivider.horizontalThin
            searchContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onDisappear {
            viewModel.viewDidDisappear()
        }
        .searchable(
            placeholder: L10n.SearchBar.placeholder,
            placeholderOnFocus: L10n.SearchBar.Focused.placeholder,
            searchText: $viewModel.searchText,
            pullToSearchConfig: .disabled,
            style: .softLarge,
            dismissConfiguration: .init(type: .back),
            contentOverlayColorWhenFocused: theme.color.surfaceBackgroundPrimary,
            showDivider: true,
            autoFocus: autoFocus,
            transition: transition,
            onCancel: { onCancel() },
            onSubmit: { _ in onSubmit() }
        )
        .background(theme.color.surfaceBackgroundPrimary)
    }
}

// MARK: - Views

extension SearchView {
    @ViewBuilder private var searchContentView: some View {
        switch viewModel.state {
        case .blank:
            Color.clear

        case .recentSearches:
            RecentSearchesView(viewModel: viewModel.recentSearchesViewModel)

        case .loading:
            LoadingSpinner(size: .medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(AccessibilityID.Search.suggestionsLoading)

        case .suggestions(let suggestions):
            ProductSuggestionsView(
                products: suggestions.products,
                onSelect: { viewModel.didTapProductSuggestion($0) },
                onMoreProducts: { viewModel.didTapMoreProducts() }
            )

        case .noResults(let searchTerm):
            suggestionsMessage(
                title: L10n.Search.Screen.Suggestions.NoResults.title(searchTerm),
                message: L10n.Search.Screen.Suggestions.NoResults.message,
                accessibilityIdentifier: AccessibilityID.Search.noResults
            )

        case .error(let searchTerm):
            suggestionsMessage(
                title: L10n.Search.Screen.Suggestions.Error.title,
                message: L10n.Search.Screen.Suggestions.Error.message(searchTerm),
                buttons: [
                    .init(
                        cta: L10n.Search.Screen.Suggestions.Error.Button.cta,
                        accessibilityId: AccessibilityID.Search.suggestionsRetryButton,
                        action: { viewModel.didTapRetrySuggestions() }
                    ),
                ],
                accessibilityIdentifier: AccessibilityID.Search.suggestionsError
            )
        }
    }

    private func suggestionsMessage(
        title: String,
        message: String,
        buttons: [ErrorView.ButtonConfiguration] = [],
        accessibilityIdentifier: String
    ) -> some View {
        ErrorView(icon: nil, title: title, message: message, buttons: buttons)
            .multilineTextAlignment(.center)
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

// MARK: - Search Actions

extension SearchView {
    private func onCancel() {
        viewModel.closeSearch()
    }

    private func onSubmit() {
        guard viewModel.isSearchSubmissionAllowed else {
            return
        }
        viewModel.onSubmitSearch()
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Blank") {
    SearchView(viewModel: MockSearchViewModel(state: .blank))
}

#Preview("Recent Searches") {
    SearchView(viewModel: MockSearchViewModel(state: .recentSearches))
}

#Preview("Loading") {
    SearchView(viewModel: MockSearchViewModel(state: .loading))
}

#Preview("Product Suggestions") {
    SearchView(
        viewModel: MockSearchViewModel(
            state: .suggestions(.fixture(products: [.fixture(id: "1"), .fixture(id: "2"), .fixture(id: "3")]))
        )
    )
}

#Preview("No Results") {
    SearchView(viewModel: MockSearchViewModel(state: .noResults(searchTerm: "zzz")))
}

#Preview("Error") {
    SearchView(viewModel: MockSearchViewModel(state: .error(searchTerm: "shirt")))
}
#endif
