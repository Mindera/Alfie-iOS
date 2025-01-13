import Common
import Models

public final class BFFClientDependencyContainer {
    public var reachabilityService: ReachabilityServiceProtocol
    public var restNetworkClient: NetworkClientProtocol

    public init(reachabilityService: ReachabilityServiceProtocol, restNetworkClient: NetworkClientProtocol) {
        self.reachabilityService = reachabilityService
        self.restNetworkClient = restNetworkClient
    }
}
