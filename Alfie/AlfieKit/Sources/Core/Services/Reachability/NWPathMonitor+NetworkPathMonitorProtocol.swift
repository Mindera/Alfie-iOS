import Combine
import Models
import Network

extension NWPathMonitor: NetworkPathMonitorProtocol {
    public var networkAvailability: AnyPublisher<Bool, Never> {
        let subject = CurrentValueSubject<Bool, Never>(currentPath.status == .satisfied)

        pathUpdateHandler = { path in
            let newStatus = path.status == .satisfied
            guard subject.value != newStatus else { return }
            subject.send(newStatus)
        }

        return subject.eraseToAnyPublisher()
    }

    public func startMonitoring(on queue: DispatchQueue) {
        start(queue: queue)
    }

    public func stopMonitoring() {
        cancel()
    }
}
