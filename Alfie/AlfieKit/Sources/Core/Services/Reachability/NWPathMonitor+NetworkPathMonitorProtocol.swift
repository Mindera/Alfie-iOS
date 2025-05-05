import Combine
import Model
import Network

extension NWPathMonitor: NetworkPathMonitorProtocol {
    public var isAvailable: Bool {
        currentPath.status == .satisfied
    }

    public func startMonitoring(on queue: DispatchQueue) {
        start(queue: queue)
    }

    public func stopMonitoring() {
        pathUpdateHandler = nil
        cancel()
    }

    public func setUpdateHandler(_ handler: @escaping (Bool) -> Void) {
        pathUpdateHandler = { path in
            handler(path.status == .satisfied)
        }
    }
}
