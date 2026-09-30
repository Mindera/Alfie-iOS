import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

public struct SearchView<ViewModel: SearchViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    private let autoFocus: Bool
    private let transition: SearchBarTransition? // Move to VM?

    public init(viewModel: ViewModel, autoFocus: Bool = true, transition: SearchBarTransition? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.autoFocus = autoFocus
        self.transition = transition
    }

    public var body: some View {
        VStack(spacing: Primitives.Spacing.spacing0) {
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
            theme: .softLarge,
            dismissConfiguration: .init(type: .back),
            contentOverlayColorWhenFocused: Primitives.Colours.neutrals0,
            showDivider: true,
            autoFocus: autoFocus,
            transition: transition,
            onCancel: { onCancel() },
            onSubmit: { _ in onSubmit() }
        )
        .background(Primitives.Colours.neutrals0)
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
