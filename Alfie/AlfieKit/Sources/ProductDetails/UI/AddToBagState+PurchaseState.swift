import Model

extension AddToBagState {
    init(_ purchaseState: VariantSelection.PurchaseState) {
        switch purchaseState {
        case .ready:
            self = .ready

        case .needsSize:
            self = .needsSize

        case .outOfStock:
            self = .outOfStock
        }
    }
}
