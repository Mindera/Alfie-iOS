public struct ProductListingSearchNavigation {
    let openSearch: () -> Void
    let goBack: () -> Void
    let editSearchTerm: () -> Void

    public static func listing(openSearch: @escaping () -> Void) -> Self {
        .init(openSearch: openSearch, goBack: {}, editSearchTerm: {})
    }

    public static func searchResults(
        goBack: @escaping () -> Void,
        editSearchTerm: @escaping () -> Void
    ) -> Self {
        .init(openSearch: {}, goBack: goBack, editSearchTerm: editSearchTerm)
    }
}
