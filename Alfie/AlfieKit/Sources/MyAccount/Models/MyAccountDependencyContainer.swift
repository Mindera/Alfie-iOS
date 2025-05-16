import Core
import Model

public final class MyAccountDependencyContainer {
    let configurationService: ConfigurationServiceProtocol
    let sessionService: SessionServiceProtocol

    public init(configurationService: ConfigurationServiceProtocol, sessionService: SessionServiceProtocol) {
        self.configurationService = configurationService
        self.sessionService = sessionService
    }
}
