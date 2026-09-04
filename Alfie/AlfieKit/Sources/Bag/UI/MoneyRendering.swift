import Model
import SharedUI

extension Optional where Wrapped == Money {
    /// The formatted amount, or an em dash where the server sent one that cannot be rendered.
    ///
    /// Printing the £0.00 that `toDomainMoney()`'s zero fallback would give states a price the
    /// shopper is not being charged: on a line it reads as "this item is free", and on the grand
    /// total it misstates what they are about to pay (Q36).
    var amountFormattedOrUnavailable: String {
        self?.amountFormatted ?? L10n.Bag.Amount.unavailable
    }
}
