import Model
import SwiftUI

public final class MyAccountFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = MyAccountRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    let intentViewBuilder: (MyAccountIntent) -> AnyView

    public init(
        serviceProvider: ServiceProviderProtocol,
        intentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) {
        self.serviceProvider = serviceProvider
        self.intentViewBuilder = intentViewBuilder
    }

    // MARK: - View Models for MyAccountRoute

    func makeAccountViewModel() -> some AccountViewModelProtocol {
        AccountViewModel(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        ) { [weak self] in
            self?.navigate($0)
        }
    }
}
