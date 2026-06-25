import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct RecentSearchesView<ViewModel: RecentSearchesViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing0) {
            recentSearchesHeader
            recentSearchesList
            Spacer()
        }
        .padding(.top, Primitives.Spacing.spacing16)
        .onDisappear {
            viewModel.viewDidDisappear()
        }
    }

    private var recentSearchesHeader: some View {
        HStack(alignment: .lastTextBaseline) {
            Text.build(theme.font.header.h3(L10n.Search.Screen.RecentSearches.Header.title))
                .accessibilityIdentifier(AccessibilityId.recentSearchHeaderTitle)
            Spacer()
            clearAllButton
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
        .padding(.bottom, Primitives.Spacing.spacing16)
    }

    private var recentSearchesList: some View {
        ForEach(viewModel.recentSearches, id: \.self) { recentSearch in
            recentSearchView(for: recentSearch)
                .padding(.vertical, Primitives.Spacing.spacing4)
        }
    }

    private func recentSearchView(for recentSearch: RecentSearch) -> some View {
        VStack {
            HStack {
                Text.build(theme.font.paragraph.normal(recentSearch.value))
                    .foregroundStyle(Primitives.Colours.neutrals800)
                    .lineLimit(1)
                Spacer()
                recentSearchRemoveButton(for: recentSearch)
            }
            .padding(.horizontal, Primitives.Spacing.spacing24)
        }
        .padding(.vertical, Primitives.Spacing.spacing8)
        .modifier(TapHighlightableModifier { viewModel.didTapRecentSearch(recentSearch) })
        .accessibilityIdentifier(AccessibilityId.recentSearchItem)
    }

    private func recentSearchRemoveButton(for recentSearch: RecentSearch) -> some View {
        Button(action: {
            withAnimation {
                viewModel.didTapRemove(on: recentSearch)
            }
        }, label: {
            Icon.close.image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Primitives.Spacing.spacing16, height: Primitives.Spacing.spacing16)
                .foregroundStyle(Primitives.Colours.neutrals800)
        })
        .accessibilityIdentifier(AccessibilityId.removeRecentSearchButton)
    }

    private var clearAllButton: some View {
        Button(action: {
            withAnimation {
                viewModel.didTapClearAll()
            }
        }, label: {
            Text.build(theme.font.small.boldUnderline(L10n.Search.Screen.RecentSearches.ClearAll.Button.cta))
                .foregroundStyle(Primitives.Colours.neutrals800)
        })
        .accessibilityIdentifier(AccessibilityId.clearRecentSearchesButton)
    }
}

private enum Constants {
    static let emptyViewSearchIconWidth: CGFloat = 48
    static let emptyViewSearchIconHeight: CGFloat = 48
}

private enum AccessibilityId {
    static let recentSearchHeaderTitle = "recent-search-title"
    static let recentSearchItem = "recent-search-item"
    static let clearRecentSearchesButton = "clear-recent-searches"
    static let removeRecentSearchButton = "remove-recent-search-item"
}

#if DEBUG
#Preview {
    RecentSearchesView(
        viewModel: RecentSearchesViewModel(recentsService: MockRecentsService()) { _ in }
    )
}
#endif
