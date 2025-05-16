import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web

public final class WishlistFlowViewModel: WishlistFlowViewModelProtocol {
    public typealias Route = WishlistRoute
    @Published public var path = NavigationPath()
    private let dependencies: WishlistFlowDependencyContainer

    public init(dependencies: WishlistFlowDependencyContainer) {
        self.dependencies = dependencies
    }

    // MARK: - View Models for WishlistRoute

    public func makeWishlistViewModel(isRoot: Bool) -> WishlistViewModel {
        WishlistViewModel(
            hasNavigationSeparator: !isRoot,
            dependencies: dependencies.wishlistDependencyContainer
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    public func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(dependencies: dependencies.myAccountDependencyContainer) { [weak self] in
            self?.navigate(.myAccount($0))
        }
    }

    public func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel {
        ProductDetailsViewModel(
            configuration: configuration,
            dependencies: dependencies.productDetailsDependencyContainer,
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.productDetails(.webFeature($0))) }
        )
    }

    public func makeWebViewModel(feature: WebFeature) -> WebViewModel {
        WebViewModel(
            webFeature: feature,
            dependencies: dependencies.webDependencyContainer
        )
    }

    // MARK: - View Models for MyAccountIntent

    public func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel(isRoot: false))
            )
        }
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: WishlistRoute) {
        if case .wishlist = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
