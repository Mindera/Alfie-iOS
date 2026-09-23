import Foundation

/// A line to write to the cart. Both ids are required: BigCommerce rejects a line without
/// `productId`, and Shopify ignores it — so sending both is the only shape that works on either
/// platform, and making them non-optional stops a caller from omitting one.
public struct CartLineInput: Hashable {
    public let productId: String
    public let variantId: String
    public let quantity: Int
    public let sku: String?
    public let slug: String?
    public let name: String?
    public let imageURL: URL?
    public let imageAltText: String?
    public let unitPrice: Money?

    public init(
        productId: String,
        variantId: String,
        quantity: Int = 1,
        sku: String? = nil,
        slug: String? = nil,
        name: String? = nil,
        imageURL: URL? = nil,
        imageAltText: String? = nil,
        unitPrice: Money? = nil
    ) {
        self.productId = productId
        self.variantId = variantId
        self.quantity = quantity
        self.sku = sku
        self.slug = slug
        self.name = name
        self.imageURL = imageURL
        self.imageAltText = imageAltText
        self.unitPrice = unitPrice
    }
}
