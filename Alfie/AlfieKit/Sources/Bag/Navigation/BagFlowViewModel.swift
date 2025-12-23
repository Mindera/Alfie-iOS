import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web
import Wishlist

public final class BagFlowViewModel: BagFlowViewModelProtocol {
    public typealias Route = BagRoute
    @Published public var path = NavigationPath()
    private let dependencies: BagFlowDependencyContainer

    public init(dependencies: BagFlowDependencyContainer) {
        self.dependencies = dependencies
    }

    // MARK: - View Models for BagRoute

    public func makeBagViewModel() -> BagViewModel {
        BagViewModel(dependencies: dependencies.bagDependencyContainer) { [weak self] in
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

    public func makeWishlistViewModel() -> WishlistViewModel {
        WishlistViewModel(
            hasNavigationSeparator: true,
            dependencies: dependencies.wishlistDependencyContainer
        ) { [weak self] in
            self?.navigate(.wishlist($0))
        }
    }

    // MARK: - View Models for MyAccountIntent

    public func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel())
            )
        }
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: BagRoute) {
        if case .bag = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
