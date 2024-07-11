import Combine
import Foundation
import Models
import Network

public final class ReachabilityMonitor: ReachabilityMonitorProtocol {
    @Published var isAvailable = false
    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }

    private let monitor = NWPathMonitor()
    private let backgroundQueue = DispatchQueue.global(qos: .background)

    deinit {
        stopMonitoring()
    }

    public init() { }

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isAvailable = path.status == .satisfied
        }

        monitor.start(queue: backgroundQueue)
    }

    public func stopMonitoring() {
        monitor.pathUpdateHandler = nil
        monitor.cancel()
    }
}
