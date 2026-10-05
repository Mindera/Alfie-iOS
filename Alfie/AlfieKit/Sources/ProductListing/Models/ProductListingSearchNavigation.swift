public enum ProductListingSearchNavigation {
    case listing(openSearch: () -> Void)
    case searchResults(goBack: () -> Void, editSearchTerm: () -> Void)
}
