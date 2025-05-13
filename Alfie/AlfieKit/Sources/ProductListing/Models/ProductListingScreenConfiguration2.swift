import Foundation

public struct ProductListingScreenConfiguration2: Equatable, Hashable {
    public let category: String?
    public let searchText: String?
    public let urlQueryParameters: [String: String]?
    public let mode: ProductListingViewMode2

    public init(
        category: String?,
        searchText: String?,
        urlQueryParameters: [String: String]?,
        mode: ProductListingViewMode2
    ) {
        self.category = category
        self.searchText = searchText
        self.urlQueryParameters = urlQueryParameters
        self.mode = mode
    }
}
