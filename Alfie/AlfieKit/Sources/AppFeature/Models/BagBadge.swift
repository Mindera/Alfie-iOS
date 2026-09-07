import Model

/// What the bag tab's badge shows for a given cart: the quantity summed across its lines, never the
/// number of lines. Nothing to count — no cart, or an empty one — means no badge at all, rather than
/// the dot `badgeView` draws for a zero.
enum BagBadge {
    static func value(for cart: Cart?) -> Int? {
        guard let quantity = cart?.totalQuantity, quantity > 0 else {
            return nil
        }
        return quantity
    }
}
