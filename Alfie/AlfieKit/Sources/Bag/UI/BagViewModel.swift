import Foundation
import Model

public final class BagViewModel: BagViewModelProtocol {
    @Published public private(set) var state: ViewState<Cart?, BFFRequestError> = .loading
    public var isWishlistEnabled: Bool

    private let dependencies: BagDependencyContainer
    private let navigate: (BagRoute) -> Void

    init(
        dependencies: BagDependencyContainer,
        navigate: @escaping (BagRoute) -> Void
    ) {
        self.isWishlistEnabled = dependencies.configurationService.isFeatureEnabled(.wishlist)
        self.dependencies = dependencies
        self.navigate = navigate
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
                state = .success(dependencies.cartService.cart)
            } catch {
                dependencies.log.error("Error removing line \(line.id) from the cart: \(error)")
            }
        }
    }

    public func didTapMyAccount() {
        navigate(.myAccount(.myAccount))
    }

    public func didTapWishlist() {
        navigate(.wishlist(.wishlist))
    }

    // MARK: - Private

    private func fetchCart() {
        state = .loading
        Task { @MainActor in
            do {
                try await dependencies.cartService.fetch()
                state = .success(dependencies.cartService.cart)
            } catch {
                dependencies.log.error("Error fetching the cart: \(error)")
                state = .error(error as? BFFRequestError ?? BFFRequestError(type: .generic, error: error))
            }
        }
    }
}
