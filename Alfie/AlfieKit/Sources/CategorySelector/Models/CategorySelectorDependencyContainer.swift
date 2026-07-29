import Model

public final class CategorySelectorDependencyContainer {
    let navigationService: NavigationServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    public init(
        navigationService: NavigationServiceProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.navigationService = navigationService
        self.configurationService = configurationService
    }
}
