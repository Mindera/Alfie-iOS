import Foundation
import Models
import StyleGuide
import SwiftUI

extension View {
    @ViewBuilder
    func withGenericSearch(pullToSearchConfig: PullToSearchConfig,
                           transition: SearchBarTransition? = nil,
                           theme: DJSearchBarView.Theme = .softLarge,
                           autoFocus: Bool = false,
                           onCancel: (() -> Void)? = nil,
                           onSubmit: ((String) -> Void)? = nil,
                           dependencies: SearchDependencyContainerProtocol = SearchResultsDependencyContainer()) -> some View {
        let viewModel = SearchResultsViewModel(dependencies: dependencies)
        let view = SearchResultsView(viewModel: viewModel)
        let searchText: Binding<String> = .init(get: { viewModel.searchText }, set: { newValue in viewModel.searchText = newValue })
        modifier(SearchableModifier(
            placeholder: LocalizableSearch.$searchBarPlaceholder,
            placeholderOnFocus: LocalizableSearch.$searchBarPlaceholderFocused,
            searchText: searchText,
            pullToSearchConfig: pullToSearchConfig,
            theme: theme,
            showCancelButton: true,
            contentOverlayColorWhenFocused: Colors.primary.white,
            showDivider: true,
            autoFocus: autoFocus,
            inputAccessibilityId: AccessibilityId.searchInput,
            clearAccessibilityId: AccessibilityId.closeBtn,
            cancelAccessibilityId: AccessibilityId.cancelBtn,
            transition: transition,
            resultsView: { view },
            onCancel: onCancel,
            onSubmit: onSubmit))
    }
}

private enum AccessibilityId {
    static let searchInput = "search-input"
    static let closeBtn = "close-btn"
    static let cancelBtn = "back-btn"
}
