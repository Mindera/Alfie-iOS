import Foundation

/// A line to write to the cart. Both ids are required: BigCommerce rejects a line without
/// `productId`, and Shopify ignores it — so sending both is the only shape that works on either
/// platform, and making them non-optional stops a caller from omitting one.
public struct CartLineInput: Hashable {
    public let productId: String
    public let variantId: String
    public let quantity: Int

    public init(productId: String, variantId: String, quantity: Int = 1) {
        self.productId = productId
        self.variantId = variantId
        self.quantity = quantity
    }
}
