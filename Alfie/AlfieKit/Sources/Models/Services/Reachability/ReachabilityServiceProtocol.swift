import Combine

public protocol ReachabilityServiceProtocol {
    var networkAvailability: AnyPublisher<Bool, Never> { get }
    var isNetworkAvailable: Bool { get }
}
