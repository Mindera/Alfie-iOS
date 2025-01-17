public protocol EventTrackerProtocol<Event> {
    associatedtype Event: EventProtocol
    init(trackingService: TrackingServiceProtocol)
    func trackEvent(event: Event)
}
