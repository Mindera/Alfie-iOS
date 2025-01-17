import Models

public final class EventTracker<TrackingEvent: EventProtocol>: EventTrackerProtocol {
    private let trackingService: TrackingServiceProtocol

    public init(trackingService: TrackingServiceProtocol) {
        self.trackingService = trackingService
    }

    public func trackEvent(event: TrackingEvent) {
        trackingService.track(name: event.name, parameters: event.parameters)
    }
}
