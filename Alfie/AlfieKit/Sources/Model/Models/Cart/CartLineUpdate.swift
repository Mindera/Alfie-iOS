import Foundation

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
    func asUpdate(quantity newQuantity: Int) -> CartLineUpdate {
        .init(id: id, productId: productId, variantId: variantId, quantity: newQuantity)
    }
}
