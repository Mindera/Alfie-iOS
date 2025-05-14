import Foundation
import Model

public class DebugMenuViewModel: ObservableObject {

    private let serviceProvider: ServiceProviderProtocol
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let closeMenuAction: () -> Void
    let openForceAppUpdate: () -> Void
    let closeEndpointSelection: () -> Void

    public init(
        serviceProvider: ServiceProviderProtocol,
        closeMenuAction: @escaping () -> Void,
        openForceAppUpdate: @escaping () -> Void,
        closeEndpointSelection: @escaping () -> Void
    ) {
        self.serviceProvider = serviceProvider
        self.closeMenuAction = closeMenuAction
        self.openForceAppUpdate = openForceAppUpdate
        self.closeEndpointSelection = closeEndpointSelection
        self.configurationService = serviceProvider.configurationService
        self.apiEndpointService = serviceProvider.apiEndpointService
    }
}
