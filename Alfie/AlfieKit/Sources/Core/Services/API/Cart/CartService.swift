import Combine
import Foundation
import Model

/// An actor, matching the other stores that own mutable state, so the cart and its id are only
/// ever touched from one isolation domain.
///
/// `cart` and `cartPublisher` are `nonisolated` on purpose: the subject carries its own
/// synchronisation — which is why the cart is held in one rather than in a stored property — and
/// that lets the bag screen and the tab badge read the last-known cart without an `await`.
/// Ordering writes is a separate problem, and one that actor isolation does not solve on its own;
/// see `add(line:)`.
public actor CartService: CartServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    private let userDefaults: UserDefaultsProtocol
    private let storageKey: String
    private let cartSubject = CurrentValueSubject<Cart?, Never>(nil)
    /// The most recently started write. Each new one waits on it, so writes run in the order they
    /// arrive rather than concurrently. See `add(line:)`.
    private var lastWrite: Task<Void, Error>?

    public nonisolated var cart: Cart? { cartSubject.value }
    public nonisolated var cartPublisher: AnyPublisher<Cart?, Never> { cartSubject.eraseToAnyPublisher() }

    public init(bffClient: BFFClientServiceProtocol, userDefaults: UserDefaultsProtocol, storageKey: String) {
        self.bffClient = bffClient
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func add(line: CartLineInput) async throws {
        // Writes run one at a time. An actor is reentrant, so two adds that both suspend on the
        // network would otherwise each see no stored id and create a cart apiece — the shopper's
        // first item left in an orphan whose id the app never kept. Nothing outside stops that:
        // the CTA guard is `ProductDetailsViewModel.isAddingToBag`, which is per screen, and a PDP
        // can sit on the stack of more than one tab at a time.
        let previous = lastWrite
        let write = Task<Void, Error> {
            // A write that fails must not fail the one queued behind it, so its result is dropped.
            _ = await previous?.result
            try await self.write(line: line)
        }
        lastWrite = write

        try await write.value
    }

    private func write(line: CartLineInput) async throws {
        // The first add creates the cart carrying the line, so create-and-add costs one round trip
        // rather than two.
        let cart: Cart
        if let cartId = storedCartId {
            cart = try await bffClient.addToCart(cartId: cartId, lines: [line])
        } else {
            cart = try await bffClient.createCart(lines: [line])
        }

        // Persisted from either branch: the returned cart is the truth, its id included. On
        // BigCommerce an append can hand back a cart whose id is not the one we asked with, and a
        // stored id that disagrees with the cart we hold is the next write aimed at the wrong one.
        userDefaults.set(cart.id, for: storageKey)
        cartSubject.send(cart)
    }

    /// The server's handle on a guest cart — a non-secret id, so `UserDefaults` is enough. There is
    /// no client-side expiry: the server's 404 is the only authoritative signal that a cart is dead.
    private var storedCartId: String? {
        userDefaults.value(for: storageKey)
    }
}
