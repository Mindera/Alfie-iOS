import Model

public final class MyAccountDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let sessionService: SessionServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol

    public init(
        configurationService: ConfigurationServiceProtocol,
        sessionService: SessionServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol
    ) {
        self.configurationService = configurationService
        self.sessionService = sessionService
        self.apiEndpointService = apiEndpointService
    }
}
