import Models

public final class MockTrackingProvider: TrackingProviderProtocol {
    public var id: String = ""
    public var isEnabled: Bool = true

    public init() {}

    public var onEnableCalled: (() -> Void)?
    public func enable() {
        onEnableCalled?()
    }
    
    public var onDisableCalled: (() -> Void)?
    public func disable() {
        onDisableCalled?()
    }
    
    public var onTrackEventCalled: ((String?, [String: Any]?) -> Void)?
    public func track(name: String?, parameters: [String: Any]?) {
        onTrackEventCalled?(name, parameters)
    }
}
