import Core
import Model
import SwiftUI

public final class SearchFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = SearchRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    let intentViewBuilder: (SearchIntent) -> AnyView
    private let closeSearchAction: () -> Void

    public init(
        serviceProvider: ServiceProviderProtocol,
        intentViewBuilder: @escaping (SearchIntent) -> AnyView,
        closeSearchAction: @escaping () -> Void
    ) {
        self.serviceProvider = serviceProvider
        self.intentViewBuilder = intentViewBuilder
        self.closeSearchAction = closeSearchAction
    }

    // MARK: - View Models for SearchRoute

    func makeSearchModel() -> some SearchViewModelProtocol {
        SearchViewModel(
            dependencies: .init(
                recentsService: serviceProvider.recentsService,
                searchService: serviceProvider.searchService,
                analytics: serviceProvider.analytics
            ),
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
