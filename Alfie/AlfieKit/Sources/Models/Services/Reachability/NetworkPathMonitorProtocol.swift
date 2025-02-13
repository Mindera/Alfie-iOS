import Combine
import Foundation

public protocol NetworkPathMonitorProtocol {
    var networkAvailability: AnyPublisher<Bool, Never> { get }

    func startMonitoring(on queue: DispatchQueue)
    func stopMonitoring()
}
