public protocol TrackingProviderProtocol {
    var id: String { get }
    var isEnabled: Bool { get }

    func enable()
    func disable()
    func track(name: String?, parameters: [String: Any]?)
}
