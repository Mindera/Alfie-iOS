import UIKit

public enum HapticType {
    /// use *.notification* when a task has succeeded, failed, or produced a warning.
    case notification(_ notification: UINotificationFeedbackGenerator.FeedbackType)
    /// use *.impact* when your UI element impacts something else with a specific intensity between 0.0 and 1.0
    case impact(intensity: CGFloat)
    /// use *.selectionChanged* that the user has changed a selection
    case selectionChanged
}
