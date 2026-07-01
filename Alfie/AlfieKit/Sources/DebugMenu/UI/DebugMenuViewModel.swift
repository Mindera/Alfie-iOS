import Foundation
import Model

public class DebugMenuViewModel: ObservableObject {
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let themeService: ThemeServiceProtocol
    let closeMenuAction: () -> Void
    let openForceAppUpdate: () -> Void
    let closeEndpointSelection: () -> Void

    public init(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        themeService: ThemeServiceProtocol,
        closeMenuAction: @escaping () -> Void,
        openForceAppUpdate: @escaping () -> Void,
        closeEndpointSelection: @escaping () -> Void
    ) {
        self.configurationService = configurationService
        self.apiEndpointService = apiEndpointService
        self.themeService = themeService
        self.closeMenuAction = closeMenuAction
        self.openForceAppUpdate = openForceAppUpdate
        self.closeEndpointSelection = closeEndpointSelection
    }
}
