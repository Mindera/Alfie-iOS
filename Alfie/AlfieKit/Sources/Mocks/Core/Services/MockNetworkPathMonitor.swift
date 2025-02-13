import Combine
import Foundation
import Models

public final class MockNetworkPathMonitor: NetworkPathMonitorProtocol {
    public var isAvailable: Bool = false {
        didSet {
            updateHandler?(isAvailable)
        }
    }
    private var updateHandler: ((Bool) -> Void)?

    public init() {}

    public var onStartMonitoringCalled: ((DispatchQueue) -> Void)?
    public func startMonitoring(on queue: DispatchQueue) {
        onStartMonitoringCalled?(queue)
    }

    public var onStopMonitoringCalled: (() -> Void)?
    public func stopMonitoring() {
        onStopMonitoringCalled?()
    }

    public func setUpdateHandler(_ handler: @escaping (Bool) -> Void) {
        updateHandler = handler
    }
}
