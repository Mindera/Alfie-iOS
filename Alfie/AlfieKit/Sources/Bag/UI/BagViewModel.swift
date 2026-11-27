import Combine
import Foundation
import Model

public final class BagViewModel: BagViewModelProtocol {
    @Published public private(set) var state: ViewState<Cart?, BFFRequestError> = .loading
    @Published public private(set) var transientFailure: BFFRequestError.BFFRequestErrorType?

    private enum ReadPhase {
        case inFlight
        case settled
        case failed(BFFRequestError)
    }

    private let dependencies: BagDependencyContainer
    private let navigate: (BagRoute) -> Void
    private var readPhase: ReadPhase = .inFlight
    private var latestReadID = 0
    private var cartSubscription: AnyCancellable?

    init(
        dependencies: BagDependencyContainer,
        navigate: @escaping (BagRoute) -> Void
    ) {
        self.dependencies = dependencies
        self.navigate = navigate

        show(dependencies.cartService.cart)
        cartSubscription = dependencies.cartService.cartPublisher
            .receive(on: dependencies.scheduler)
            .sink { [weak self] in self?.cartDidChange(to: $0) }
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

    // MARK: - Private

    private func fetchCart() {
        if !state.isSuccess {
            state = .loading
        }
        readPhase = .inFlight
        transientFailure = nil
        latestReadID += 1
        let readID = latestReadID
        Task { @MainActor in
            do {
                try await dependencies.cartService.fetch()
                guard readID == latestReadID else { return }
                readPhase = .settled
            } catch {
                dependencies.log.error("Error fetching the cart: \(error)")
                guard readID == latestReadID else { return }
                let error = error as? BFFRequestError ?? BFFRequestError(type: .generic, error: error)
                readPhase = .failed(error)
                if Self.hasLines(dependencies.cartService.cart) {
                    transientFailure = error.type
                }
            }
            show(dependencies.cartService.cart)
        }
    }

    private func cartDidChange(to cart: Cart?) {
        // A failed read publishes nothing, so a Cart arriving over a Blocking error is news.
        if case .failed = readPhase {
            readPhase = .settled
        }
        show(cart)
    }

    private func show(_ cart: Cart?) {
        if Self.hasLines(cart) {
            readPhase = .settled
            state = .success(cart)
            return
        }
        switch readPhase {
        case .inFlight where !state.isSuccess:
            break

        case .inFlight, .settled:
            state = .success(cart)

        case .failed(let error):
            state = .error(error)
        }
    }

    private static func hasLines(_ cart: Cart?) -> Bool {
        cart?.lines.isEmpty == false
    }
}
