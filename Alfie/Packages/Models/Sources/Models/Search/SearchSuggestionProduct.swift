import Foundation

public struct SearchSuggestionProduct: Identifiable, Equatable, Hashable {
    /// Unique ID for the product.
    public let id: String
    /// The formal name of the product.
    public let name: String
    /// The name of the brand for the product.
    public let brandName: String
    /// Array of images and videos.
    public let media: [Media]
    /// How much does it cost?
    public let price: Price
    /// For building a navigation link to the product.
    public let slug: String

    public init(id: String,
                name: String,
                brandName: String,
                media: [Media],
                price: Price,
                slug: String) {
        self.id = id
        self.name = name
        self.brandName = brandName
        self.media = media
        self.price = price
        self.slug = slug
    }

    public static func == (lhs: SearchSuggestionProduct, rhs: SearchSuggestionProduct) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
