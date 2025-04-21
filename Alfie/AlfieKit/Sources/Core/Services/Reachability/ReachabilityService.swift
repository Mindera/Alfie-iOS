import Combine
import Foundation
import Model
import Utils

public final class ReachabilityService: ReachabilityServiceProtocol {
    private let monitor: NetworkPathMonitorProtocol
    private let monitorQueue: DispatchQueue
    @Published private var isAvailable: Bool
    private var subscriptions = Set<AnyCancellable>()

    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }
    public var isNetworkAvailable: Bool { isAvailable }

    deinit {
        stopMonitoring()
    }

    public init(
        monitor: NetworkPathMonitorProtocol,
        monitorQueue: DispatchQueue = DispatchQueue(label: "com.mindera.alfiekit.reachability", qos: .utility)
    ) {
        self.monitor = monitor
        self.monitorQueue = monitorQueue
        self.isAvailable = monitor.isAvailable
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.setUpdateHandler { [weak self] newStatus in
            guard let self, isAvailable != newStatus else { return }
            isAvailable = newStatus
        }
        monitor.startMonitoring(on: monitorQueue)
    }

    private func stopMonitoring() {
        monitor.stopMonitoring()
    }
}
