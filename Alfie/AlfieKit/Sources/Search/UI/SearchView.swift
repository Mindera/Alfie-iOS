import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct SearchView<ViewModel: SearchViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    private let transition: SearchBarTransition? // Move to VM?

    public init(viewModel: ViewModel, transition: SearchBarTransition? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.transition = transition
    }

    public var body: some View {
        VStack(spacing: Spacing.space0) {
            ThemedDivider.horizontalThin
            Spacer()
            searchContentView
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
            theme: .softLarge,
            dismissConfiguration: .init(type: .back),
            contentOverlayColorWhenFocused: Colors.primary.white,
            showDivider: true,
            autoFocus: true,
            transition: transition,
            onCancel: { onCancel() },
            onSubmit: { _ in onSubmit() }
        )
        .background(Colors.primary.white)
    }
}

// MARK: - Views

extension SearchView {
    @ViewBuilder private var searchContentView: some View {
        // swiftlint:disable vertical_whitespace_between_cases
        switch viewModel.state {
        case .empty:
            emptyView
        case .loading:
            loadingView
        case .noResults:
            noResultsView
        case .recentSearches:
            RecentSearchesView(viewModel: viewModel.recentSearchesViewModel)
        case .success:
            resultsView
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.space200) {
            Spacer()
            LoaderView(circleDiameter: .defaultSmall)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.space200) {
            Spacer()
            imageForIcon(Icon.search)
            Text.build(theme.font.paragraph.bold(L10n.Search.Screen.EmptyView.title))
                .foregroundStyle(Colors.primary.black)
            Text.build(theme.font.small.normal(L10n.Search.Screen.EmptyView.message))
                .foregroundStyle(Colors.primary.black)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityId.emptyView)
    }

    private var noResultsView: some View {
        VStack(alignment: .leading, spacing: Spacing.space400) {
            Text.build(
                theme.font.paragraph.normal(
                    L10n.Search.Screen.NoResultsView.term(viewModel.searchText)
                )
            )
                .foregroundStyle(Colors.primary.mono900)
            Text.build(theme.font.paragraph.normal(L10n.Search.Screen.NoResultsView.message))
                .foregroundStyle(Colors.primary.mono900)
            Button(action: {
                openBrands()
            }, label: {
                Text.build(theme.font.paragraph.normalUnderline(L10n.Search.Screen.NoResultsView.link))
                    .foregroundStyle(Colors.primary.mono900)
            })
            .accessibilityIdentifier(AccessibilityId.brandsListLink)
            Spacer()
        }
        .padding(Spacing.space200)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.noResultsView)
    }

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: Spacing.space400) {
                suggestionTerms
                suggestionBrands
                suggestionProducts

                ThemedButton(text: L10n.Search.Screen.Suggestions.More.Button.cta, style: .secondary) { onSubmit() }
                    .accessibilityIdentifier(AccessibilityId.moreProductsCta)
            }
            .padding(Spacing.space200)
        }
    }

    @ViewBuilder private var suggestionTerms: some View {
        if !viewModel.suggestionTerms.isEmpty {
            LazyVStack(spacing: Spacing.space200) {
                suggestionHeader(text: L10n.Search.Screen.SuggestionsTerms.Header.title)
                    .accessibilityIdentifier(AccessibilityId.suggestionsTermsTitle)
                ForEach(viewModel.suggestionTerms, id: \.self) { suggestion in
                    Button(action: {
                        viewModel.onTapSearchSuggestion(suggestion)
                    }, label: {
                        suggestionEntry(text: suggestion.term)
                    })
                }
            }
        }
    }

    @ViewBuilder private var suggestionBrands: some View {
        if !viewModel.suggestionBrands.isEmpty {
            LazyVStack(spacing: Spacing.space200) {
                suggestionHeader(text: L10n.Search.Screen.SuggestionsBrands.Header.title)
                    .accessibilityIdentifier(AccessibilityId.suggestionsBrandsTitle)
                ForEach(viewModel.suggestionBrands, id: \.self) { brand in
                    Button(action: {
                        viewModel.onTapSearchBrand(brand)
                    }, label: {
                        suggestionEntry(text: brand.name)
                    })
                }
            }
        }
    }

    @ViewBuilder private var suggestionProducts: some View {
        if !viewModel.suggestionProducts.isEmpty {
            VStack(spacing: Spacing.space150) {
                suggestionHeader(text: L10n.Search.Screen.SuggestionsProducts.Header.title)
                    .accessibilityIdentifier(AccessibilityId.suggestionsProductsTitle)
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top),
                        count: Constants.productCardsPerLine
                    ),
                    spacing: Spacing.space200
                ) {
                    ForEach(viewModel.suggestionProducts) { product in
                        productCardView(product)
                    }
                }
            }
        }
    }
}

// MARK: - Helpers

extension SearchView {
    private func imageForIcon(_ icon: Icon) -> some View {
        icon.image
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(Colors.primary.black)
            .scaledToFit()
            .frame(width: Constants.iconSize, height: Constants.iconSize)
    }

    private func suggestionHeader(text: String) -> some View {
        HStack(spacing: Spacing.space0) {
            Text.build(theme.font.header.h3(text))
                .foregroundStyle(Colors.primary.black)
            Spacer()
        }
    }

    private func suggestionEntry(text: String) -> some View {
        HStack(spacing: Spacing.space0) {
            Text.build(
                theme.font.paragraph.normal(text),
                highlighting: viewModel.searchText,
                font: theme.font.paragraph.bold,
                color: Colors.primary.black
            )
            .foregroundStyle(Colors.primary.mono900)
            Spacer()
        }
        .accessibilityIdentifier(AccessibilityId.suggestionsItem)
    }

    private func productCardView(_ product: Product) -> some View {
        VerticalProductCard(
            viewModel: .init(
                configuration: .init(size: .medium, hidePrice: true, hideAction: true),
                product: product
            )
        ) { _, _ in }
        .onTapGesture {
            viewModel.onTapProduct(product)
        }
    }

    private func openBrands() {
        hideKeyboard()
        viewModel.onTapOpenBrands()
        // Delay closing the search screen to avoid a flicker while changing tabs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.closeSearch()
        }
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

// MARK: - Accessibility Id's

private enum AccessibilityId {
    static let emptyView = "empty-screen"
    static let noResultsView = "no-results-screen"
    static let suggestionsTermsTitle = "search-suggestions-title"
    static let suggestionsItem = "suggestions-item"
    static let suggestionsProductsTitle = "product-suggestions-title"
    static let suggestionsBrandsTitle = "brand-suggestions-title"
    static let moreProductsCta = "more-products-cta"
    static let brandsListLink = "brands-list-link"
}

// MARK: - Constants

private enum Constants {
    static let iconSize: CGFloat = 48
    static let searchBarAnimatingOpacity: Double = 0
    static let searchBarNonAnimatingOpacity: Double = 1
    static let searchBarAnimatingEffectWith: CGFloat = 0.1
    static let searchBarNonAnimatingEffectWith: CGFloat = 1
    static let searchBarEffectHeight: CGFloat = 1
    static let decelerateDurationUntilCompletion: CGFloat = 0.25
    static let productCardsPerLine = 2
}

// MARK: - Previews

#if DEBUG
#Preview("Empty") {
    SearchView(viewModel: MockSearchViewModel(state: .empty))
}

#Preview("Loading") {
    SearchView(viewModel: MockSearchViewModel(state: .loading))
}

#Preview("No Results") {
    SearchView(viewModel: MockSearchViewModel(state: .noResults, searchText: "Polo"))
}

#Preview("Results") {
    SearchView(
        viewModel: MockSearchViewModel(
            state: .success(suggestion: .fixture()),
            searchText: "polo",
            suggestionTerms: [
                .fixture(term: "Polo shirt"), .fixture(term: "Apolo Denim"), .fixture(term: "Casual polos")
            ],
            suggestionBrands: [.fixture(name: "Polo by Ralph Lauren"), .fixture(name: "Apolo Denim")],
            suggestionProducts: Product.fixtures
        )
    )
}
#endif
