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
            .safeAreaInset(edge: .top, spacing: Primitives.Spacing.spacing0) {
                VStack(spacing: Primitives.Spacing.spacing0) {
                    HStack(spacing: Primitives.Spacing.spacing8) {
                        ThemedBackButton(
                            accessibilityIdentifier: AccessibilityID.ProductListing.searchBackButton,
                            action: backAction
                        )

                        SearchBarEntryButton(
                            placeholder: L10n.SearchBar.placeholder,
                            searchTerm: searchTerm,
                            accessibilityIdentifier: AccessibilityID.ProductListing.searchBarButton,
                            action: searchBarAction
                        )
                    }
                    .padding(.horizontal, Primitives.Spacing.spacing16)
                    .padding(.vertical, Primitives.Spacing.spacing8)

                    ThemedDivider.horizontalThin
                }
                .background(Primitives.Colours.neutrals0)
            }
    }
}
