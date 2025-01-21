import Combine
import Models

public final class TrackingService: TrackingServiceProtocol {
    private let providers: [TrackingProviderProtocol]
    private var enabledProviders: [TrackingProviderProtocol] {
        providers.filter(\.isEnabled)
    }

    public private(set) var trackedEvents: [TrackedEvent]

    public init(providers: [TrackingProviderProtocol]) {
        self.providers = providers
        self.trackedEvents = []
    }

    public func enableAllProviders() {
        providers.forEach {
            $0.enable()
        }
    }

    public func disableAllProviders() {
        providers.forEach {
            $0.disable()
        }
    }

    public func track(name: String?, parameters: [String: Any]?) {
        enabledProviders.forEach { provider in
            provider.track(name: name, parameters: parameters)
            #warning("Add IF DEBUG clause when removing DebugMenu from release version")
            trackedEvents.append(TrackedEvent(
                name: name,
                providers: enabledProviders.map(\.id)
            ))
        }
    }
}
