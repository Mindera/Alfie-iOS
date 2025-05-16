import Core
import Model

public final class HomeDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let sessionService: SessionServiceProtocol

    public init(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        sessionService: SessionServiceProtocol
    ) {
        self.configurationService = configurationService
        self.apiEndpointService = apiEndpointService
        self.sessionService = sessionService
    }
}
