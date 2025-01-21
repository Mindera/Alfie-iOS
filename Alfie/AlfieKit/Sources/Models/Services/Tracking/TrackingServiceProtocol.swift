import Combine

public protocol TrackingServiceProtocol {
    var trackedEvents: [TrackedEvent] { get }

    func enableAllProviders()
    func disableAllProviders()
    func track(name: String?, parameters: [String: Any]?)
}
