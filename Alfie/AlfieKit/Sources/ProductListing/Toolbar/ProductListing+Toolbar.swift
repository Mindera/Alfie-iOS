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
                        accessibilityId: AccessibilityID.titleHeader
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
                        Button(action: backAction) {
                            ThemedIcon(
                                .chevronLeft,
                                size: .medium,
                                tint: Primitives.Colours.neutrals800,
                                accessibilityLabel: L10n.Accessibility.back
                            )
                        }
                        .accessibilityIdentifier(AccessibilityIdentifiers.AccessibilityID.ProductListing.searchBackButton)

                        SearchBarEntryButton(
                            placeholder: L10n.SearchBar.placeholder,
                            searchTerm: searchTerm,
                            accessibilityIdentifier: AccessibilityIdentifiers.AccessibilityID.ProductListing.searchBar,
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

// MARK: - AccessibilityId

private enum AccessibilityID {
    static let titleHeader = "title-header"
}
