import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.CartFragment {
    func convertToCart() -> Cart {
        Cart(
            id: id,
            lines: lineItems.map { $0.fragments.cartItemFragment.convertToCartLine() },
            subtotal: totals.subtotal.fragments.moneyFragment.toDomainMoneyIfRenderable(),
            grandTotal: totals.grandTotal.fragments.moneyFragment.toDomainMoneyIfRenderable()
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
            imageAltText: image?.altText,
            quantity: quantity,
            unitPrice: price.fragments.moneyFragment.toDomainMoneyIfRenderable(),
            lineTotal: lineTotal.fragments.moneyFragment.toDomainMoneyIfRenderable()
        )
    }
}

extension BFFGraphAPI.CartLineInput {
    init(domain: Model.CartLineInput) {
        self.init(productId: .some(domain.productId), quantity: domain.quantity, variantId: domain.variantId)
    }
}

// MARK: - Diagnostics

extension Cart {
    /// The field paths carrying an amount the BFF sent in a form this app cannot represent — either
    /// non-finite or outside `Decimal`'s range (see `MoneyFragment.decimalAmount`). Empty for a
    /// healthy cart, which is every real one.
    ///
    /// The bag renders `—` for these rather than the fabricated £0.00 a zero fallback would print.
    /// That is right for the shopper and invisible to us: nobody reports a dash, so without this the
    /// BFF defect behind it would never surface. `BFFClientService` logs the result.
    ///
    /// Reports the path, not the offending value. The value is already gone by the time a `Cart`
    /// exists, and threading a logger through every converter to capture it would cost more than the
    /// extra detail returns — the path plus the cart id is enough to go and look at the response.
    var unrepresentableAmountFields: [String] {
        var fields: [String] = []
        if subtotal == nil { fields.append("subtotal") }
        if grandTotal == nil { fields.append("grandTotal") }
        for line in lines {
            if line.unitPrice == nil { fields.append("line[\(line.id)].unitPrice") }
            if line.lineTotal == nil { fields.append("line[\(line.id)].lineTotal") }
        }
        return fields
    }
}
