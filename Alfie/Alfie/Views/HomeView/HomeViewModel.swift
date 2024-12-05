import Models

struct HomeViewModel: HomeViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol

    var toolbarModifierViewModel: DefaultToolbarModifierViewModelProtocol {
        DefaultToolbarModifierViewModel(configurationService: configurationService)
    }

    init(configurationService: ConfigurationServiceProtocol) {
        self.configurationService = configurationService
    }
}

