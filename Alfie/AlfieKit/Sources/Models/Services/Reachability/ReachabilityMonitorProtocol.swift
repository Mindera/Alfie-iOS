import Combine

public protocol ReachabilityMonitorProtocol {
    var networkAvailability: AnyPublisher<Bool, Never> { get }

    func startMonitoring()
    func stopMonitoring()
}
