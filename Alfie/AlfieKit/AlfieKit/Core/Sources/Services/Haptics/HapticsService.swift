import Models
import UIKit

public final class HapticsService: HapticsServiceProtocol {
    private lazy var notificationGenerator = UINotificationFeedbackGenerator()
    private lazy var impactGenerator = UIImpactFeedbackGenerator()
    private lazy var selectionGenerator = UISelectionFeedbackGenerator()
    public static let instance = HapticsService()

    /// Informs self that it will likely receive events soon, so that it can ensure minimal latency for any feedback generated
    /// safe to call more than once before the generator receives an event, if events are still imminently possible
    public func prepare(for hapticType: HapticType) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch hapticType {
        case .notification:
            notificationGenerator.prepare()
        case .impact:
            impactGenerator.prepare()
        case .selectionChanged:
            selectionGenerator.prepare()
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    public func trigger(_ hapticType: HapticType) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch hapticType {
        case .notification(let feedbackType):
            trigger(notification: feedbackType)
        case .impact(let intensity):
            trigger(impactIntensity: intensity)
        case .selectionChanged:
            triggerSelectionChanged()
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private func trigger(notification: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(notification)
    }

    private func trigger(impactIntensity: CGFloat) {
        impactGenerator.impactOccurred(intensity: impactIntensity)
    }

    private func triggerSelectionChanged() {
        selectionGenerator.selectionChanged()
    }
}
