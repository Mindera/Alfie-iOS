import Foundation
import Model

public class DebugMenuViewModel: ObservableObject {
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let bffApiKeyService: BFFApiKeyServiceProtocol
    let closeMenuAction: () -> Void
    let openForceAppUpdate: () -> Void
    let closeEndpointSelection: () -> Void

    public init(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        bffApiKeyService: BFFApiKeyServiceProtocol,
        closeMenuAction: @escaping () -> Void,
        openForceAppUpdate: @escaping () -> Void,
        closeEndpointSelection: @escaping () -> Void
    ) {
        self.configurationService = configurationService
        self.apiEndpointService = apiEndpointService
        self.bffApiKeyService = bffApiKeyService
        self.closeMenuAction = closeMenuAction
        self.openForceAppUpdate = openForceAppUpdate
        self.closeEndpointSelection = closeEndpointSelection
    }
}
