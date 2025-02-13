import Combine
import Common
import Foundation
import Models

public final class ReachabilityService: ReachabilityServiceProtocol {
    private let monitor: NetworkPathMonitorProtocol
    @Published private var isAvailable = false
    private var subscriptions = Set<AnyCancellable>()

    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }
    public var isNetworkAvailable: Bool { isAvailable }

    deinit {
        monitor.stopMonitoring()
    }

    public init(
        monitor: NetworkPathMonitorProtocol,
        monitorQueue: DispatchQueue = DispatchQueue(label: "com.mindera.alfiekit.reachability", qos: .utility)
    ) {
        self.monitor = monitor

        monitor.networkAvailability
            .assignWeakly(to: \.isAvailable, on: self)
            .store(in: &subscriptions)

        monitor.startMonitoring(on: monitorQueue)
    }
}
