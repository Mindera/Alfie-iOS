import Combine
import Foundation

public protocol NetworkPathMonitorProtocol {
    var isAvailable: Bool { get }

    func startMonitoring(on queue: DispatchQueue)
    func stopMonitoring()
    func setUpdateHandler(_ handler: @escaping (Bool) -> Void)
}
