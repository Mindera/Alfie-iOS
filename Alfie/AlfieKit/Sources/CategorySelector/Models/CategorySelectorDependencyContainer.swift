import Model

public final class CategorySelectorDependencyContainer {
    let navigationService: NavigationServiceProtocol
    let brandsService: BrandsServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    public init(
        navigationService: NavigationServiceProtocol,
        brandsService: BrandsServiceProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.navigationService = navigationService
        self.brandsService = brandsService
        self.configurationService = configurationService
    }
}
