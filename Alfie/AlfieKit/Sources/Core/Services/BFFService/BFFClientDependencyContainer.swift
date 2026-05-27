import Model
import Utils

public final class BFFClientDependencyContainer {
    public var reachabilityService: ReachabilityServiceProtocol
    public var restNetworkClient: NetworkClientProtocol
    public var errorReporter: BFFErrorReporterProtocol?

    public init(
        reachabilityService: ReachabilityServiceProtocol,
        restNetworkClient: NetworkClientProtocol,
        errorReporter: BFFErrorReporterProtocol? = nil
    ) {
        self.reachabilityService = reachabilityService
        self.restNetworkClient = restNetworkClient
        self.errorReporter = errorReporter
    }
}
