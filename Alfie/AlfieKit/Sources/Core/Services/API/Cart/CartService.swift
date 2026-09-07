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
    /// The most recently started cart operation. Each new one waits on it, so operations run in
    /// the order they arrive rather than concurrently. See `add(line:)`.
    private var lastOperation: Task<Void, Error>?

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

    /// Runs `operation` after every cart operation already queued. An actor is reentrant, so
    /// unordered operations interleave in ways that cost the shopper an item: two adds each see no
    /// stored id and create a cart apiece, leaving the first item in an orphan whose id the app
    /// never kept; and a remove that overtakes an add has its cart overwritten by the add's older
    /// one, putting the swiped-away row back on screen. Nothing outside stops either — the CTA
    /// guard is `ProductDetailsViewModel.isAddingToBag`, which covers one screen, and a PDP can sit
    /// on the stack of more than one tab at a time.
    ///
    /// Reads queue here too, for read-after-write ordering. A `getCart` issued while a remove is
    /// still in flight can be answered from the pre-removal cart — arriving later does not make a
    /// response newer, since it may have been *sent* before the write was applied — and publishing
    /// it puts the swiped-away row back on screen. The cost is that a slow read delays the write
    /// behind it, which is the right trade at one screen and one cart.
    private func serialised(_ operation: @escaping @Sendable () async throws -> Void) async throws {
        let previous = lastOperation
        let task = Task<Void, Error> {
            // One that fails must not fail the one queued behind it, so its result is dropped.
            _ = await previous?.result
            try await operation()
        }
        lastOperation = task

        try await task.value
    }

    public func fetch() async throws {
        try await serialised { try await self.read() }
    }

    private func read() async throws {
        guard let cartId = storedCartId else {
            cartSubject.send(nil)
            return
        }

        do {
            cartSubject.send(try await bffClient.getCart(cartId: cartId))
        } catch let error as BFFRequestError where error.type == .cart(.cartNotFound) {
            // The bag opens empty rather than erroring. The cart is genuinely gone, so an ErrorView
            // offering a retry would only fail the same way, and the shopper cannot act on it.
            // Every other failure propagates with the id intact — a server having a bad day is not
            // a reason to throw away a live cart.
            forgetCart()
        }
    }

    public func remove(lineId: String) async throws {
        try await serialised { try await self.dropLine(id: lineId) }
    }

    private func dropLine(id lineId: String) async throws {
        // No stored id means no cart on the server, so the line cannot be dropped. This throws
        // rather than returning: a silent success would have the caller fire `remove_from_bag` and
        // republish an unchanged cart for a removal that never happened.
        guard let cartId = storedCartId else {
            throw BFFRequestError(type: .generic)
        }

        let cart = try await bffClient.removeFromCart(cartId: cartId, lineId: lineId)
        // Persisted for the same reason `write(line:)` does it: every mutation returns the complete
        // cart, id included, and a stored id that disagrees with the cart we hold is the next
        // operation aimed at the wrong one.
        userDefaults.set(cart.id, for: storageKey)
        cartSubject.send(cart)
    }

    private func write(line: CartLineInput) async throws {
        // The first add creates the cart carrying the line, so create-and-add costs one round trip
        // rather than two.
        let cart: Cart
        if let cartId = storedCartId {
            cart = try await append(line: line, to: cartId)
        } else {
            cart = try await bffClient.createCart(lines: [line])
        }

        // Persisted from either branch: the returned cart is the truth, its id included. On
        // BigCommerce an append can hand back a cart whose id is not the one we asked with, and a
        // stored id that disagrees with the cart we hold is the next write aimed at the wrong one.
        userDefaults.set(cart.id, for: storageKey)
        cartSubject.send(cart)
    }

    /// Appends to the stored cart, and starts a fresh one carrying the same line if the server no
    /// longer knows it. Both happen inside the shopper's single tap, so a cart that expired between
    /// visits costs them one extra round trip and nothing else — they see the ordinary success
    /// snackbar and never learn anything went wrong.
    ///
    /// The dead id is dropped before the retry rather than after it: the server has already told us
    /// that cart is gone, so keeping it through a `createCart` that then fails would leave the next
    /// add aimed at a cart we know does not exist.
    private func append(line: CartLineInput, to cartId: String) async throws -> Cart {
        do {
            return try await bffClient.addToCart(cartId: cartId, lines: [line])
        } catch let error as BFFRequestError where error.type == .cart(.cartNotFound) {
            discardStoredCartId()
            return try await bffClient.createCart(lines: [line])
        }
    }

    /// Drops the stored id and the held cart. Called on sign-out, so a shared device does not hand
    /// the next shopper the previous one's bag; the server does not bind a guest cart to an account,
    /// so this side simply stops pointing at it.
    ///
    /// Queued like every other operation, so a write already in flight cannot re-persist the id
    /// this is dropping. Nothing here can fail, hence the discarded error.
    public func discardCart() async {
        try? await serialised { await self.forgetCart() }
    }

    private func forgetCart() {
        discardStoredCartId()
        cartSubject.send(nil)
    }

    private func discardStoredCartId() {
        userDefaults.remove(for: storageKey)
    }

    /// The server's handle on a guest cart — a non-secret id, so `UserDefaults` is enough. There is
    /// no client-side expiry: the server's 404 is the only authoritative signal that a cart is dead.
    private var storedCartId: String? {
        userDefaults.value(for: storageKey)
    }
}
