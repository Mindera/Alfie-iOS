import Model

public final class HomeDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let bffApiKeyService: BFFApiKeyServiceProtocol
    let sessionService: SessionServiceProtocol

    public init(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        bffApiKeyService: BFFApiKeyServiceProtocol,
        sessionService: SessionServiceProtocol
    ) {
        self.configurationService = configurationService
        self.apiEndpointService = apiEndpointService
        self.bffApiKeyService = bffApiKeyService
        self.sessionService = sessionService
    }
}
