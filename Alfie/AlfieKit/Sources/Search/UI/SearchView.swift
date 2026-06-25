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
        VStack(spacing: Primitives.Spacing.spacing0) {
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
            contentOverlayColorWhenFocused: Primitives.Colours.neutrals0,
            showDivider: true,
            autoFocus: true,
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
        case .empty:
            emptyView
        case .recentSearches:
            RecentSearchesView(viewModel: viewModel.recentSearchesViewModel)
        }
    }

    private var emptyView: some View {
        VStack(spacing: Primitives.Spacing.spacing16) {
            Spacer()
            imageForIcon(Icon.search)
            Text.build(theme.font.paragraph.bold(L10n.Search.Screen.EmptyView.title))
                .foregroundStyle(Primitives.Colours.neutrals900)
            Text.build(theme.font.small.normal(L10n.Search.Screen.EmptyView.message))
                .foregroundStyle(Primitives.Colours.neutrals900)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityId.emptyView)
    }
}

// MARK: - Helpers

extension SearchView {
    private func imageForIcon(_ icon: Icon) -> some View {
        icon.image
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(Primitives.Colours.neutrals900)
            .scaledToFit()
            .frame(width: Constants.iconSize, height: Constants.iconSize)
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
}

// MARK: - Constants

private enum Constants {
    static let iconSize: CGFloat = 48
}

// MARK: - Previews

#if DEBUG
#Preview("Empty") {
    SearchView(viewModel: MockSearchViewModel(state: .empty))
}

#Preview("Recent Searches") {
    SearchView(viewModel: MockSearchViewModel(state: .recentSearches))
}
#endif
