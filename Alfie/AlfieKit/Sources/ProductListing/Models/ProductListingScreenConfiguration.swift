import Foundation
import Model

public struct ProductListingScreenConfiguration: Equatable, Hashable {
    public let category: String?
    public let searchText: String?
    public let urlQueryParameters: [String: String]?
    public let mode: ProductListingViewMode

    public init(
        category: String?,
        searchText: String?,
        urlQueryParameters: [String: String]?,
        mode: ProductListingViewMode
    ) {
        self.category = category
        self.searchText = searchText
        self.urlQueryParameters = urlQueryParameters
        self.mode = mode
    }
}
