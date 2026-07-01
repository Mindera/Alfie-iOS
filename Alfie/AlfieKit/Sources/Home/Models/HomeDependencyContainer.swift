import Model

public final class HomeDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let apiEndpointService: ApiEndpointServiceProtocol
    let sessionService: SessionServiceProtocol
    let themeService: ThemeServiceProtocol

    public init(
        configurationService: ConfigurationServiceProtocol,
        apiEndpointService: ApiEndpointServiceProtocol,
        sessionService: SessionServiceProtocol,
        themeService: ThemeServiceProtocol
    ) {
        self.configurationService = configurationService
        self.apiEndpointService = apiEndpointService
        self.sessionService = sessionService
        self.themeService = themeService
    }
}
