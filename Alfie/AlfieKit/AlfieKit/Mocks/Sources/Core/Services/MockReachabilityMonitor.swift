import Combine
import Foundation
import Models

public final class MockReachabilityMonitor: ReachabilityMonitorProtocol {
    @Published var isAvailable = false

    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }

    public init() { }

    public var onStartMonitoringCalled: (() -> Void)?
    public func startMonitoring() {
        onStartMonitoringCalled?()
    }

    public var onStopMonitoringCalled: (() -> Void)?
    public func stopMonitoring() {
        onStopMonitoringCalled?()
    }

    // MARK: - Helpers

    public func simulateNetworkAvailability(available: Bool, after: TimeInterval = 0.0) {
        DispatchQueue.global().asyncAfter(deadline: .now() + after) {
            self.isAvailable = available
        }
    }
}
