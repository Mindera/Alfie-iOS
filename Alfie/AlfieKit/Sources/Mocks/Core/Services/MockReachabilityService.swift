import Combine
import Foundation
import Models

public final class MockReachabilityService: ReachabilityServiceProtocol {
    @Published var isAvailable = true // By default have reachability to avoid tests unrelated with connection from failing

    public var networkAvailability: AnyPublisher<Bool, Never> { $isAvailable.eraseToAnyPublisher() }
    public var isNetworkAvailable: Bool { isAvailable }

    public init() { }

    // MARK: - Helpers
    
    public func simulateNetworkAvailability(available: Bool, after: TimeInterval = 0.0) {
        DispatchQueue.global().asyncAfter(deadline: .now() + after) {
            self.isAvailable = available
        }
    }
}
