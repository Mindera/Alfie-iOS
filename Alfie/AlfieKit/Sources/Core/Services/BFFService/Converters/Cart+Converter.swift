import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.CartFragment {
    func convertToCart() -> Cart {
        Cart(
            id: id,
            lines: lineItems.map { $0.fragments.cartItemFragment.convertToCartLine() },
            subtotal: totals.subtotal.fragments.moneyFragment.toDomainMoney(),
            grandTotal: totals.grandTotal.fragments.moneyFragment.toDomainMoney()
        )
    }
}

extension BFFGraphAPI.CartItemFragment {
    func convertToCartLine() -> CartLine {
        CartLine(
            id: id,
            // `productId` / `variantId` are nullable on the BFF, but every line the app creates
            // sends both (BigCommerce rejects a line without `productId`). An empty string keeps a
            // server-side line the shopper is being charged for visible rather than dropping it.
            productId: productId ?? "",
            variantId: variantId ?? "",
            sku: sku,
            name: name,
            imageURL: image.flatMap { URL(string: $0.url) },
            quantity: quantity,
            unitPrice: price.fragments.moneyFragment.toDomainMoney(),
            lineTotal: lineTotal.fragments.moneyFragment.toDomainMoney()
        )
    }
}

extension BFFGraphAPI.CartLineInput {
    init(domain: Model.CartLineInput) {
        self.init(productId: .some(domain.productId), quantity: domain.quantity, variantId: domain.variantId)
    }
}
