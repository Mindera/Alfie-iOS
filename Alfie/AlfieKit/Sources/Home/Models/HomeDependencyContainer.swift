import Model

public final class HomeDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let bffApiKeyService: BffApiKeyServiceProtocol
    let sessionService: SessionServiceProtocol

    public init(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        bffApiKeyService: BffApiKeyServiceProtocol,
        sessionService: SessionServiceProtocol
    ) {
        self.configurationService = configurationService
        self.apiEndpointService = apiEndpointService
        self.bffApiKeyService = bffApiKeyService
        self.sessionService = sessionService
    }
}
