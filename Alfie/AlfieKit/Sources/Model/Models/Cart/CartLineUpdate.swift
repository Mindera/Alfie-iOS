import Foundation

/// A line's new quantity. `updateCart` takes the cart's whole `lines` array rather than the one
/// line that changed, so a caller sends every line it wants to keep — which is why this carries the
/// server's line `id`, unlike `CartLineInput`, which describes a line that does not exist yet.
///
/// Both product ids ride along for the same reason they do on `CartLineInput`: BigCommerce rejects
/// a line without them and Shopify ignores them.
public struct CartLineUpdate: Hashable {
    public let id: String
    public let productId: String
    public let variantId: String
    public let quantity: Int

    public init(id: String, productId: String, variantId: String, quantity: Int) {
        self.id = id
        self.productId = productId
        self.variantId = variantId
        self.quantity = quantity
    }
}

public extension CartLine {
    /// The line as `updateCart` wants it, carrying its current quantity. Every line in the cart has
    /// to be sent on every update, and all but one of them are unchanged.
    func update(quantity newQuantity: Int) -> CartLineUpdate {
        .init(id: id, productId: productId, variantId: variantId, quantity: newQuantity)
    }
}
