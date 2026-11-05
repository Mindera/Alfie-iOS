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
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            recentSearchesHeader
            recentSearchesList
            Spacer()
        }
        .padding(.top, theme.sizing.spacingSpacingMd)
        .onDisappear {
            viewModel.viewDidDisappear()
        }
    }

    private var recentSearchesHeader: some View {
        Text.build(theme.font.heading.small(L10n.Search.Screen.RecentSearches.Header.title))
            .accessibilityIdentifier(AccessibilityId.recentSearchHeaderTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
            .padding(.bottom, theme.sizing.spacingSpacingMd)
    }

    private var recentSearchesList: some View {
        ForEach(viewModel.recentSearches, id: \.self) { recentSearch in
            recentSearchView(for: recentSearch)
                .padding(.vertical, theme.sizing.spacingSpacing2xs)
        }
    }

    private func recentSearchView(for recentSearch: RecentSearch) -> some View {
        VStack {
            HStack {
                Text.build(theme.font.body.medium(recentSearch.value))
                    .foregroundStyle(theme.color.contentContentPrimary)
                    .lineLimit(1)
                Spacer()
                recentSearchRemoveButton(for: recentSearch)
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
        .padding(.vertical, theme.sizing.spacingSpacingXs)
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
                .frame(width: theme.sizing.iconsIconSmall, height: theme.sizing.iconsIconSmall)
                .foregroundStyle(theme.color.contentContentPrimary)
        })
        .accessibilityIdentifier(AccessibilityId.removeRecentSearchButton)
        .accessibilityLabel(Text(L10n.Accessibility.removeRecentSearch))
    }
}

private enum AccessibilityId {
    static let recentSearchHeaderTitle = "recent-search-title"
    static let recentSearchItem = "recent-search-item"
    static let removeRecentSearchButton = "remove-recent-search-item"
}

#if DEBUG
#Preview {
    RecentSearchesView(
        viewModel: RecentSearchesViewModel(recentsService: MockRecentsService()) { _ in }
    )
}
#endif
