import Foundation

public struct BarcodeMatch: Equatable {
    public let productId: String
    public let variantId: String?

    public init(productId: String, variantId: String?) {
        self.productId = productId
        self.variantId = variantId
    }
}
