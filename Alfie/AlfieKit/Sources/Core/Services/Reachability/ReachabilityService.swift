import Combine
import Foundation
import Models
import Network

public final class ReachabilityService: ReachabilityServiceProtocol {
    @Published private var isAvailable = false
    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }
    public var isNetworkAvailable: Bool { isAvailable }

    private let monitor = NWPathMonitor()
    private let utilityQueue = DispatchQueue(label: "com.mindera.alfiekit", qos: .utility)

    deinit {
        stopMonitoring()
    }

    public init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let newStatus = path.status == .satisfied
            guard self?.isAvailable != newStatus else { return }
            self?.isAvailable = newStatus
        }
        monitor.start(queue: utilityQueue)
    }

    private func stopMonitoring() {
        monitor.pathUpdateHandler = nil
        monitor.cancel()
    }
}
