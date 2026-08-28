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
        try await serialised { try await self.write(line: line) }
    }

    /// Runs `write` after every write already queued. An actor is reentrant, so unordered writes
    /// interleave in two ways that both cost the shopper an item: two adds each see no stored id
    /// and create a cart apiece, leaving the first item in an orphan whose id the app never kept;
    /// and a remove that overtakes an add has its cart overwritten by the add's older one, putting
    /// the swiped-away row back on screen. Nothing outside stops either — the CTA guard is
    /// `ProductDetailsViewModel.isAddingToBag`, which covers one screen, and a PDP can sit on the
    /// stack of more than one tab at a time.
    private func serialised(_ write: @escaping @Sendable () async throws -> Void) async throws {
        let previous = lastWrite
        let task = Task<Void, Error> {
            // A write that fails must not fail the one queued behind it, so its result is dropped.
            _ = await previous?.result
            try await write()
        }
        lastWrite = task

        try await task.value
    }

    public func fetch() async throws {
        guard let cartId = storedCartId else {
            cartSubject.send(nil)
            return
        }
        cartSubject.send(try await bffClient.getCart(cartId: cartId))
    }

    public func remove(lineId: String) async throws {
        try await serialised { try await self.dropLine(id: lineId) }
    }

    private func dropLine(id lineId: String) async throws {
        // No stored id means no cart on the server, so there is no line there to drop.
        guard let cartId = storedCartId else { return }
        cartSubject.send(try await bffClient.removeFromCart(cartId: cartId, lineId: lineId))
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
