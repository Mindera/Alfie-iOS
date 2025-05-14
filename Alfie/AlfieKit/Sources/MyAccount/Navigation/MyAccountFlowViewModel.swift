import Model
import SwiftUI

public final class MyAccountFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    let intentViewBuilder: (MyAccountIntent) -> AnyView

    public init(
        serviceProvider: ServiceProviderProtocol,
        intentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) {
        self.serviceProvider = serviceProvider
        self.intentViewBuilder = intentViewBuilder
    }

    func makeAccountViewModel() -> some AccountViewModelProtocol2 {
        AccountViewModel2(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    private func navigate(_ route: MyAccountRoute) {
        path.append(route)
    }
}
