import Foundation
import Model

extension Cart {
    public static func fixture(id: String = "cart-1",
                               lines: [CartLine] = [],
                               subtotal: Money = .fixture(),
                               grandTotal: Money = .fixture()) -> Cart {
        .init(id: id,
              lines: lines,
              subtotal: subtotal,
              grandTotal: grandTotal)
    }
}

extension CartLine {
    public static func fixture(id: String = "line-1",
                               productId: String = "product-1",
                               variantId: String = "variant-1",
                               sku: String? = "sku-1",
                               name: String? = "Product",
                               imageURL: URL? = nil,
                               imageAltText: String? = nil,
                               quantity: Int = 1,
                               unitPrice: Money = .fixture(),
                               lineTotal: Money = .fixture()) -> CartLine {
        .init(id: id,
              productId: productId,
              variantId: variantId,
              sku: sku,
              name: name,
              imageURL: imageURL,
              imageAltText: imageAltText,
              quantity: quantity,
              unitPrice: unitPrice,
              lineTotal: lineTotal)
    }
}
