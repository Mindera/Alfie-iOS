import Model
import Utils

public final class BFFClientDependencyContainer {
    public var reachabilityService: ReachabilityServiceProtocol
    public var restNetworkClient: NetworkClientProtocol
    public var apiKeyService: BffApiKeyServiceProtocol
    public var errorReporter: BFFErrorReporterProtocol?

    public init(
        reachabilityService: ReachabilityServiceProtocol,
        restNetworkClient: NetworkClientProtocol,
        apiKeyService: BffApiKeyServiceProtocol,
        errorReporter: BFFErrorReporterProtocol? = nil
    ) {
        self.reachabilityService = reachabilityService
        self.restNetworkClient = restNetworkClient
        self.apiKeyService = apiKeyService
        self.errorReporter = errorReporter
    }
}
