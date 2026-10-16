import Foundation
import Model

extension ProductDetailsViewModel {
    public var bagQuantity: Int {
        guard let bagLine else { return 0 }

        if let pendingBagQuantity, pendingBagQuantity.lineId == bagLine.id {
            return pendingBagQuantity.quantity
        }
        return bagLine.quantity
    }

    public var maxBagQuantity: Int {
        min(selectedVariant?.stock ?? 0, Constants.maxLineQuantity)
    }

    private var bagLine: CartLine? {
        guard
            let variantId = selectedVariant?.id,
            variantSelection.sizeDisplay != .selector || variantSelection.selectedSize != nil
        else {
            return nil
        }

        return cart?.lines.first { $0.variantId == variantId }
    }

    public func didTapAddToBag() {
        // `isAddingToBag` flips before the Task is started, so a second tap while the first write
        // is still in flight is rejected here rather than becoming a second request.
        guard
            !isAddingToBag,
            let variant = selection.purchaseState.readyVariant,
            let variantId = variant.id,
            let product
        else {
            return
        }
        let selectedProduct = SelectedProduct(product: product, selectedVariant: variant)

        // Cleared up front so a second write with the same outcome is still a change the View
        // observes, rather than being swallowed as an unchanged value.
        addToBagFeedback = nil
        isAddingToBag = true
        Task { @MainActor in
            defer { isAddingToBag = false }
            do {
                // `product.id`, not `selectedProduct.id`: the latter is the composite
                // "<productId>-<sku>" used for local identity, which no platform would resolve.
                try await dependencies.cartService.add(
                    line: .init(productId: product.id, variantId: variantId)
                )
                // Only once the cart holds the line — firing on the tap would count adds that failed.
                // The composite id here is the pre-existing analytics shape, left alone.
                dependencies.analytics.trackAddToBag(productID: selectedProduct.id)
                addToBagFeedback = .success
            } catch {
                dependencies.log.error("Error adding \(selectedProduct.id) to the cart: \(error)")
                addToBagFeedback = .failure
            }
        }
    }

    public func didTapIncreaseBagQuantity() {
        guard bagQuantity < maxBagQuantity else { return }

        stepBagQuantity(to: bagQuantity + 1)
    }

    public func didTapDecreaseBagQuantity() {
        guard bagQuantity > 0 else { return }

        stepBagQuantity(to: bagQuantity - 1)
    }

    public func didDismissAddToBagFeedback() {
        // Cleared on dismissal so an identical later outcome re-presents rather than being
        // swallowed as an unchanged value.
        addToBagFeedback = nil
    }

    private func stepBagQuantity(to quantity: Int) {
        guard !isUpdatingBagQuantity, !isAddingToBag, let line = bagLine else { return }

        pendingBagQuantity = .init(lineId: line.id, quantity: quantity)
        // Zero removes the line and takes Add to bag's place, so it writes at once: a removal left
        // pending behind a visible Add to bag would race a fresh add.
        guard quantity > 0 else {
            bagQuantityDebounce.cancel()
            commitPendingBagQuantity()
            return
        }

        bagQuantityDebounce.schedule { [weak self] in self?.commitPendingBagQuantity() }
    }

    private func commitPendingBagQuantity() {
        guard
            !isUpdatingBagQuantity,
            let pending = pendingBagQuantity,
            let line = cart?.lines.first(where: { $0.id == pending.lineId }),
            pending.quantity != line.quantity,
            let selectedProduct
        else {
            pendingBagQuantity = nil
            return
        }

        let isIncrease = pending.quantity > line.quantity
        addToBagFeedback = nil
        isUpdatingBagQuantity = true
        Task { @MainActor in
            defer {
                cart = dependencies.cartService.cart
                pendingBagQuantity = nil
                isUpdatingBagQuantity = false
            }
            do {
                try await dependencies.cartService.setQuantity(lineId: line.id, to: pending.quantity)
                if isIncrease {
                    dependencies.analytics.trackAddToBag(productID: selectedProduct.id)
                } else {
                    dependencies.analytics.trackRemoveFromBag(productID: selectedProduct.id)
                }
            } catch {
                dependencies.log.error("Error setting line \(line.id) to quantity \(pending.quantity): \(error)")
                addToBagFeedback = .quantityUpdateFailure
            }
        }
    }
}

struct PendingBagQuantity: Equatable {
    let lineId: String
    let quantity: Int
}

private enum Constants {
    static let maxLineQuantity = 100
}
