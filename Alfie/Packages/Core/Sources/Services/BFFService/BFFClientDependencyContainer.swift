import Common
import Models

public protocol BFFClientDependencyContainerProtocol {
    var reachabilityService: ReachabilityServiceProtocol { get }
    var restNetworkClient: NetworkClientProtocol { get }
}

public final class BFFClientDependencyContainer: BFFClientDependencyContainerProtocol {
    public var reachabilityService: ReachabilityServiceProtocol
    public var restNetworkClient: NetworkClientProtocol

    public init(reachabilityService: ReachabilityServiceProtocol,
                restNetworkClient: NetworkClientProtocol) {
        self.reachabilityService = reachabilityService
        self.restNetworkClient = restNetworkClient
    }
}
