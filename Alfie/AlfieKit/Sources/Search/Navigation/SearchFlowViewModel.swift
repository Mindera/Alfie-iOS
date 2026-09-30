import Combine
import Core
import Model
import SwiftUI

public final class SearchFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = SearchRoute
    @Published public var path = NavigationPath()
    @Published public private(set) var isPresented = false
    @Published public private(set) var focusesSearchBarOnAppear = true
    private let dependencies: SearchDependencyContainer
    let intentViewBuilder: (SearchIntent) -> AnyView

    public var overlayViewPublisher: AnyPublisher<AnyView?, Never> {
        $isPresented
            .map { [weak self] isPresented in
                guard let self, isPresented else { return nil }
                return AnyView(SearchFlowView(viewModel: self))
            }
            .eraseToAnyPublisher()
    }

    public var isSearchScreenOnTopPublisher: AnyPublisher<Bool, Never> {
        $isPresented
            .combineLatest($path.map(\.isEmpty))
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public init(
        dependencies: SearchDependencyContainer,
        intentViewBuilder: @escaping (SearchIntent) -> AnyView
    ) {
        self.dependencies = dependencies
        self.intentViewBuilder = intentViewBuilder
    }

    // MARK: - View Models for SearchRoute

    func makeSearchModel() -> some SearchViewModelProtocol {
        SearchViewModel(
            dependencies: dependencies,
            navigate: { [weak self] in self?.navigate($0) },
            closeSearchAction: { [weak self] in self?.close() }
        )
    }

    public func present() {
        isPresented = true
    }

    public func close() {
        isPresented = false
        reset()
    }

    private func reset() {
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
