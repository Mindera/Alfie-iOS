import Core
import Model
import SwiftUI

public final class SearchFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = SearchRoute
    @Published public var path = NavigationPath()
    private let dependencies: SearchDependencyContainer
    let intentViewBuilder: (SearchIntent) -> AnyView
    private let closeSearchAction: () -> Void

    public init(
        dependencies: SearchDependencyContainer,
        intentViewBuilder: @escaping (SearchIntent) -> AnyView,
        closeSearchAction: @escaping () -> Void
    ) {
        self.dependencies = dependencies
        self.intentViewBuilder = intentViewBuilder
        self.closeSearchAction = closeSearchAction
    }

    // MARK: - View Models for SearchRoute

    func makeSearchModel() -> some SearchViewModelProtocol {
        SearchViewModel(
            dependencies: dependencies,
            navigate: { [weak self] in self?.navigate($0) },
            closeSearchAction: { [weak self] in self?.closeSearchAction() }
        )
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: SearchRoute) {
        if case .search = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
