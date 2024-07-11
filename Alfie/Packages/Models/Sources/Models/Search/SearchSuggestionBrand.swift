import Foundation

public struct SearchSuggestionBrand: Identifiable, Equatable, Hashable {
    /// Local Unique ID for the instance (not mapped to any remote value)
    public let id: String
    /// Name of the brand.
    public let name: String
    /// Number of products matching the brand.
    public let resultCount: Int
    /// Slugified name of the brand.
    public let slug: String

    public init(id: String = UUID().uuidString,
                name: String,
                slug: String,
                resultCount: Int) {
        self.id = id
        self.name = name
        self.slug = slug
        self.resultCount = resultCount
    }
}
