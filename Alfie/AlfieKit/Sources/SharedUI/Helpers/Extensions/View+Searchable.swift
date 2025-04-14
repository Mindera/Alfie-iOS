import SwiftUI

extension View {
    public func searchable(
        placeholder: String,
        placeholderOnFocus: String,
        searchText: Binding<String>,
        pullToSearchConfig: PullToSearchConfig = .disabled,
        theme: ThemedSearchBarView.Theme,
        dismissConfiguration: ThemedSearchBarView.DismissConfiguration,
        verticalSpacing: CGFloat = Spacing.space100,
        showCancelButton: Bool = true,
        contentOverlayColorWhenFocused: Color? = .black.opacity(0.5),
        showDivider: Bool = false,
        autoFocus: Bool = false,
        transition: SearchBarTransition? = nil,
        onCancel: (() -> Void)? = nil,
        onSubmit: ((String) -> Void)? = nil,
        inputAccessibilityId: String? = nil,
        clearAccessibilityId: String? = nil,
        @ViewBuilder resultsView: @escaping () -> some View = { EmptyView() }
    ) -> some View {
        modifier(
            SearchableModifier(
                placeholder: placeholder,
                placeholderOnFocus: placeholderOnFocus,
                searchText: searchText,
                pullToSearchConfig: pullToSearchConfig,
                theme: theme,
                dismissConfiguration: dismissConfiguration,
                verticalSpacing: verticalSpacing,
                showCancelButton: showCancelButton,
                contentOverlayColorWhenFocused: contentOverlayColorWhenFocused,
                showDivider: showDivider,
                autoFocus: autoFocus,
                inputAccessibilityId: inputAccessibilityId,
                clearAccessibilityId: clearAccessibilityId,
                transition: transition,
                resultsView: resultsView,
                onCancel: onCancel,
                onSubmit: onSubmit
            )
        )
    }
}
