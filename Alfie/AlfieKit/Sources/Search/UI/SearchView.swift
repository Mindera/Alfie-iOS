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

// MARK: - Previews

#if DEBUG
#Preview("Blank") {
    SearchView(viewModel: MockSearchViewModel(state: .blank))
}

#Preview("Recent Searches") {
    SearchView(viewModel: MockSearchViewModel(state: .recentSearches))
}
#endif
