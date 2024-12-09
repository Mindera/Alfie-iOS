import Core
import Models

final class BagDependencyContainer: BagDependencyContainerProtocol {
    let bagService: BagServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    init(bagService: BagServiceProtocol, configurationService: ConfigurationServiceProtocol) {
        self.bagService = bagService
        self.configurationService = configurationService
    }
}
