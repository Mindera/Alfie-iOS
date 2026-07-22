import Model
import SwiftUI

public final class MyAccountFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = MyAccountRoute
    @Published public var path = NavigationPath()
    private let dependencies: MyAccountFlowDependencyContainer
    let intentViewBuilder: (MyAccountIntent) -> AnyView
    /// When set, tapping Wishlist routes to the dedicated Wishlist tab instead of pushing it here.
    public var onSelectWishlist: (() -> Void)?

    public init(
        dependencies: MyAccountFlowDependencyContainer,
        intentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) {
        self.dependencies = dependencies
        self.intentViewBuilder = intentViewBuilder
    }

    // MARK: - View Models for MyAccountRoute

    func makeAccountViewModel() -> some AccountViewModelProtocol {
        AccountViewModel(dependencies: dependencies.myAccountDependencyContainer) { [weak self] in
            self?.navigate($0)
        }
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: MyAccountRoute) {
        if case .myAccountIntent(.wishlist) = route, let onSelectWishlist {
            onSelectWishlist()
            return
        }
        if case .myAccount = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
