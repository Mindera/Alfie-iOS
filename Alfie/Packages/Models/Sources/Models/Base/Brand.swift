import Foundation

public struct Brand: Identifiable, Equatable {
    /// The ID for the brand
    public let id: String
    /// The display name of the brand
    public let name: String
    /// A slugified name for URL usage
    public let slug: String

    public init(id: String = UUID().uuidString,
                name: String,
                slug: String) {
        self.id = id
        self.name = name
        self.slug = slug
    }
}
