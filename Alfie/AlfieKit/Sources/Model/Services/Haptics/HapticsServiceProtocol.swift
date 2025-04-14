public protocol HapticsServiceProtocol {
    func prepare(for hapticType: HapticType)
    func trigger(_ hapticType: HapticType)
}
