import AccessibilityIdentifiers
import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        configuration: ProductListingScreenConfiguration,
        showSearchButton: Bool,
        openSearchAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: true,
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    ThemedToolbarTitle(
                        style: .text(configuration.category.orEmpty),
                        accessibilityId: AccessibilityID.ProductListing.titleHeader
                    )
                },
                trailingItems: {
                    if showSearchButton {
                        ToolbarItemProvider.searchItem(size: .normal, openSearchAction: openSearchAction)
                    } else {
                        EmptyView()
                    }
                }
            )
        )
    }

    func searchResultsToolbarView(
        searchTerm: String,
        backAction: @escaping () -> Void,
        searchBarAction: @escaping () -> Void
    ) -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: theme.sizing.spacingSpacingNone) {
                VStack(spacing: theme.sizing.spacingSpacingNone) {
                    HStack(spacing: theme.sizing.spacingSpacingXs) {
                        ThemedBackButton(
                            accessibilityIdentifier: AccessibilityID.ProductListing.searchBackButton,
                            action: backAction
                        )

                        SearchBarEntryButton(
                            placeholder: L10n.SearchBar.placeholder,
                            searchTerm: searchTerm,
                            accessibilityIdentifier: AccessibilityID.ProductListing.searchBarButton,
                            style: .softMedium,
                            action: searchBarAction
                        )
                    }
                    .padding(.horizontal, theme.sizing.spacingSpacingMd)
                    .frame(height: Constants.searchResultsHeaderHeight)

                    ThemedDivider.horizontalThin
                }
                .background(theme.color.surfaceBackgroundPrimary)
            }
    }
}

private enum Constants {
    static let searchResultsHeaderHeight: CGFloat = 48
}
