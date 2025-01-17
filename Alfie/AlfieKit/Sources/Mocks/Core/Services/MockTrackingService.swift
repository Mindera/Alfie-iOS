import Combine
import Models

public class MockTrackingService: TrackingServiceProtocol {
    public init() {}

    public var trackedEvents: [TrackedEvent] = []
    public var trackedEventsPublisher: AnyPublisher<[Models.TrackedEvent], Never> = Just([]).eraseToAnyPublisher()

    public var onEnableAllProvidersCalled: (() -> Void)?
    public func enableAllProviders() {
        onEnableAllProvidersCalled?()
    }
    
    public var onDisableAllProvidersCalled: (() -> Void)?
    public func disableAllProviders() {
        onDisableAllProvidersCalled?()
    }
    
    public var onTrackEventCalled: ((String?, [String: Any]?) -> Void)?
    public func track(name: String?, parameters: [String: Any]?) {
        onTrackEventCalled?(name, parameters)
    }
}
