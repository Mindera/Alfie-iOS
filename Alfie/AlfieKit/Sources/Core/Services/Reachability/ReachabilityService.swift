import Combine
import Models

public final class ReachabilityService: ReachabilityServiceProtocol {
    @Published var isAvailable = false
    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }
    public var isNetworkAvailable: Bool { isAvailable }

    private var monitor: ReachabilityMonitorProtocol

    deinit {
        monitor.stopMonitoring()
    }

    public init(monitor: ReachabilityMonitorProtocol) {
        self.monitor = monitor
        monitor.networkAvailability.assign(to: &$isAvailable)
        monitor.startMonitoring()
    }
}
