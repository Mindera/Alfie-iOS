import Combine
import Foundation
import Model

/// The PDP's writes to the bag: adding the chosen variant, and stepping its line's quantity.
///
/// Owns every piece of bag state, so the rules on it — one write in flight, quantity steps
/// debounced into one write, analytics only once the cart holds the change — live in one place.
final class BagLineEditor: ObservableObject {
    @Published private(set) var isAdding = false
    @Published private(set) var isUpdating = false
    @Published private(set) var feedback: AddToBagFeedback?
    @Published private var cart: Cart?
    @Published private var pendingQuantity: PendingQuantity?
    private let dependencies: ProductDetailsDependencyContainer
    private let debounce: Debounce
    private var cartSubscription: AnyCancellable?

    init(dependencies: ProductDetailsDependencyContainer) {
        self.dependencies = dependencies
        self.debounce = Debounce(scheduler: dependencies.scheduler, delay: Constants.debounce)

        cartSubscription = dependencies.cartService.cartPublisher
            .receive(on: dependencies.scheduler)
            .sink { [weak self] cart in
                self?.cart = cart
            }
    }

    func quantity(of item: SelectedProduct) -> Int {
        guard let line = line(for: item) else { return 0 }

        if let pendingQuantity, pendingQuantity.lineId == line.id {
            return pendingQuantity.quantity
        }
        return line.quantity
    }

    func maxQuantity(of variant: Product.Variant?) -> Int {
        min(variant?.stock ?? 0, Constants.maxLineQuantity)
    }

    func add(_ item: SelectedProduct) {
        // `isAdding` flips before the Task is started, so a second tap while the first write
        // is still in flight is rejected here rather than becoming a second request.
        guard !isAdding, let variantId = item.selectedVariant.id else { return }

        // Cleared up front so a second write with the same outcome is still a change the View
        // observes, rather than being swallowed as an unchanged value.
        feedback = nil
        isAdding = true
        Task { @MainActor in
            defer { isAdding = false }
            do {
                // `product.id`, not `item.id`: the latter is the composite "<productId>-<sku>"
                // used for local identity, which no platform would resolve.
                try await dependencies.cartService.add(
                    line: .init(productId: item.product.id, variantId: variantId)
                )
                // Only once the cart holds the line — firing on the tap would count adds that failed.
                // The composite id here is the pre-existing analytics shape, left alone.
                dependencies.analytics.trackAddToBag(productID: item.id)
                feedback = .success
            } catch {
                dependencies.log.error("Error adding \(item.id) to the cart: \(error)")
                feedback = .failure
            }
        }
    }

    func increase(_ item: SelectedProduct) {
        let quantity = quantity(of: item)
        guard quantity < maxQuantity(of: item.selectedVariant) else { return }

        step(item, to: quantity + 1)
    }

    func decrease(_ item: SelectedProduct) {
        let quantity = quantity(of: item)
        guard quantity > 0 else { return }

        step(item, to: quantity - 1)
    }

    func dismissFeedback() {
        // Cleared on dismissal so an identical later outcome re-presents rather than being
        // swallowed as an unchanged value.
        feedback = nil
    }

    private func line(for item: SelectedProduct) -> CartLine? {
        guard let variantId = item.selectedVariant.id else { return nil }

        return cart?.lines.first { $0.variantId == variantId }
    }

    private func step(_ item: SelectedProduct, to quantity: Int) {
        guard !isUpdating, !isAdding, let line = line(for: item) else { return }

        pendingQuantity = .init(lineId: line.id, quantity: quantity)
        // Zero removes the line and takes Add to bag's place, so it writes at once: a removal left
        // pending behind a visible Add to bag would race a fresh add.
        guard quantity > 0 else {
            debounce.cancel()
            commitPendingQuantity(of: item)
            return
        }

        debounce.schedule { [weak self] in self?.commitPendingQuantity(of: item) }
    }

    private func commitPendingQuantity(of item: SelectedProduct) {
        guard
            !isUpdating,
            let pending = pendingQuantity,
            let line = cart?.lines.first(where: { $0.id == pending.lineId }),
            pending.quantity != line.quantity
        else {
            pendingQuantity = nil
            return
        }

        let isIncrease = pending.quantity > line.quantity
        feedback = nil
        isUpdating = true
        Task { @MainActor in
            defer {
                cart = dependencies.cartService.cart
                pendingQuantity = nil
                isUpdating = false
            }
            do {
                try await dependencies.cartService.setQuantity(lineId: line.id, to: pending.quantity)
                if isIncrease {
                    dependencies.analytics.trackAddToBag(productID: item.id)
                } else {
                    dependencies.analytics.trackRemoveFromBag(productID: item.id)
                }
            } catch {
                dependencies.log.error("Error setting line \(line.id) to quantity \(pending.quantity): \(error)")
                feedback = .quantityUpdateFailure
            }
        }
    }
}

private struct PendingQuantity: Equatable {
    let lineId: String
    let quantity: Int
}

private enum Constants {
    static let maxLineQuantity = 100
    static let debounce: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
}
