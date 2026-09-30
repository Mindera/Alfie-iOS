import Combine
import Core
import Model
import SwiftUI

public final class SearchFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = SearchRoute
    @Published public var path = NavigationPath()
    @Published public private(set) var focusesSearchBarOnAppear = true
    private let dependencies: SearchDependencyContainer
    let intentViewBuilder: (SearchIntent) -> AnyView
    private let closeSearchAction: () -> Void

    public var isSearchScreenOnTopPublisher: AnyPublisher<Bool, Never> {
        $path.map(\.isEmpty).removeDuplicates().eraseToAnyPublisher()
    }

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
            closeSearchAction: { [weak self] in
                self?.reset()
                self?.closeSearchAction()
            }
        )
    }

    public func reset() {
        focusesSearchBarOnAppear = true
        popToRoot()
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: SearchRoute) {
        switch route {
        case .search:
            reset()

        case .searchIntent:
            focusesSearchBarOnAppear = false
            path.append(route)
        }
    }
}
