import Combine
import Foundation
import Model

public final class BagViewModel: BagViewModelProtocol {
    @Published public private(set) var state: ViewState<Cart?, BFFRequestError> = .loading
    @Published public private(set) var transientFailure: BFFRequestError.BFFRequestErrorType?
    public var isWishlistEnabled: Bool

    private enum Read {
        case inFlight
        case settled
        case failed(BFFRequestError)
    }

    private let dependencies: BagDependencyContainer
    private let navigate: (BagRoute) -> Void
    private var read: Read = .inFlight
    private var cartSubscription: AnyCancellable?

    init(
        dependencies: BagDependencyContainer,
        navigate: @escaping (BagRoute) -> Void
    ) {
        self.isWishlistEnabled = dependencies.configurationService.isFeatureEnabled(.wishlist)
        self.dependencies = dependencies
        self.navigate = navigate

        show(dependencies.cartService.cart)
        cartSubscription = dependencies.cartService.cartPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.show($0) }
    }

    // MARK: - BagViewModelProtocol

    public func viewDidAppear() {
        fetchCart()
    }

    public func didTapRetry() {
        fetchCart()
    }

    public func didSelectDelete(_ line: CartLine) {
        Task { @MainActor in
            do {
                try await dependencies.cartService.remove(lineId: line.id)
                // Only once the server has dropped the line. Firing on the swipe would count
                // removals that failed.
                dependencies.analytics.trackRemoveFromBag(productID: line.productId)
            } catch {
                dependencies.log.error("Error removing line \(line.id) from the cart: \(error)")
                // The bag is left exactly as it was, so without this the row just snaps back and
                // the shopper is told nothing.
                transientFailure = (error as? BFFRequestError)?.type ?? .generic
            }
        }
    }

    public func didSelectLine(_ line: CartLine) {
        // The slug is the product handle the PDP is fetched by, and there is no fetch-by-id path to
        // fall back on — so a line without one goes nowhere rather than to a handle that cannot
        // resolve.
        guard let slug = line.slug else {
            return
        }
        navigate(.productDetails(.productDetails(.deepLink(handle: slug, sku: line.sku, variantId: line.variantId))))
    }

    public func didDismissTransientFailure() {
        transientFailure = nil
    }

    public func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    public func didTapWishlist() {
        navigate(.wishlist(.wishlist))
    }

    // MARK: - Private

    private func fetchCart() {
        if !state.isSuccess {
            state = .loading
        }
        read = .inFlight
        transientFailure = nil
        Task { @MainActor in
            do {
                try await dependencies.cartService.fetch()
                read = .settled
            } catch {
                dependencies.log.error("Error fetching the cart: \(error)")
                let error = error as? BFFRequestError ?? BFFRequestError(type: .generic, error: error)
                if Self.hasLines(dependencies.cartService.cart) {
                    read = .settled
                    transientFailure = error.type
                } else {
                    read = .failed(error)
                }
            }
            show(dependencies.cartService.cart)
        }
    }

    private func show(_ cart: Cart?) {
        if Self.hasLines(cart) {
            read = .settled
            state = .success(cart)
            return
        }
        switch read {
        case .inFlight:
            if state.isSuccess {
                state = .success(cart)
            }

        case .settled:
            state = .success(cart)

        case .failed(let error):
            state = .error(error)
        }
    }

    private static func hasLines(_ cart: Cart?) -> Bool {
        cart?.lines.isEmpty == false
    }
}
