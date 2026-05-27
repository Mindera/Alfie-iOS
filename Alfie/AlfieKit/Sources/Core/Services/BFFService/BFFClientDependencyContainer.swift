import Model
import Utils

public final class BFFClientDependencyContainer {
    public var reachabilityService: ReachabilityServiceProtocol
    public var restNetworkClient: NetworkClientProtocol
    public var errorTelemetry: BFFErrorTelemetryProtocol?

    public init(
        reachabilityService: ReachabilityServiceProtocol,
        restNetworkClient: NetworkClientProtocol,
        errorTelemetry: BFFErrorTelemetryProtocol? = nil
    ) {
        self.reachabilityService = reachabilityService
        self.restNetworkClient = restNetworkClient
        self.errorTelemetry = errorTelemetry
    }
}
