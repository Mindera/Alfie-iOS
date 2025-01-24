import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct RecentSearchesView<ViewModel: RecentSearchesViewModelProtocol>: View {
    @ObservedObject private var viewModel: ViewModel
    @EnvironmentObject private var coordinator: Coordinator

    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Spacing.space0) {
            recentSearchesHeader
            recentSearchesList
            Spacer()
        }
        .padding(.top, Spacing.space200)
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
        .padding(.horizontal, Spacing.space200)
        .padding(.bottom, Spacing.space200)
    }

    private var recentSearchesList: some View {
        ForEach(viewModel.recentSearches, id: \.self) { recentSearch in
            recentSearchView(for: recentSearch)
                .padding(.vertical, Spacing.space050)
        }
    }

    private func recentSearchView(for recentSearch: RecentSearch) -> some View {
        VStack {
            HStack {
                Text.build(theme.font.paragraph.normal(recentSearch.value))
                    .foregroundStyle(Colors.primary.mono900)
                    .lineLimit(1)
                Spacer()
                recentSearchRemoveButton(for: recentSearch)
            }
            .padding(.horizontal, Spacing.space300)
        }
        .padding(.vertical, Spacing.space100)
        .modifier(TapHighlightableModifier { coordinator.didTap(recentSearch) })
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
                .frame(width: Spacing.space200, height: Spacing.space200)
                .foregroundStyle(Colors.primary.mono900)
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
                .foregroundStyle(Colors.primary.mono900)
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
    RecentSearchesView(viewModel: RecentSearchesViewModel(recentsService: MockRecentsService()))
}
#endif
