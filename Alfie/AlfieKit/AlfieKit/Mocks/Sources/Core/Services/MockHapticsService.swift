import Models

public final class MockHapticsService: HapticsServiceProtocol {
    var onPrepareCalled: ((HapticType) -> Void)?
    var onTriggerCalled: ((HapticType) -> Void)?

    public init() {}

    public func prepare(for hapticType: HapticType) {
        onPrepareCalled?(hapticType)
    }
    
    public func trigger(_ hapticType: HapticType) {
        onTriggerCalled?(hapticType)
    }
}
