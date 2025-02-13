import Combine
import Foundation
import Models

public final class MockNetworkPathMonitor: NetworkPathMonitorProtocol {
    @Published private var isAvailable = false
    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }

    public init() {}

    public var onStartMonitoringCalled: ((DispatchQueue) -> Void)?
    public func startMonitoring(on queue: DispatchQueue) {
        onStartMonitoringCalled?(queue)
    }

    public var onStopMonitoringCalled: (() -> Void)?
    public func stopMonitoring() {
        onStopMonitoringCalled?()
    }

    // MARK: - Helpers
    
    public func simulateNetworkAvailability(available: Bool) {
        isAvailable = available
    }
}
