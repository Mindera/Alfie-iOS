import Model

public final class MockHapticsService: HapticsServiceProtocol {
    public var onPrepareCalled: ((HapticType) -> Void)?
    public var onTriggerCalled: ((HapticType) -> Void)?

    public init() {}

    public func prepare(for hapticType: HapticType) {
        onPrepareCalled?(hapticType)
    }
    
    public func trigger(_ hapticType: HapticType) {
        onTriggerCalled?(hapticType)
    }
}
