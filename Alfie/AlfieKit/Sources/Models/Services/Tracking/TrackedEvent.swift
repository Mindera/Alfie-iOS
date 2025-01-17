import Foundation

public struct TrackedEvent: Identifiable, Hashable {
    public let id = UUID()
    public let name: String?
    public let providers: [String]
    public let trackedDate: Date

    public init(name: String?, providers: [String]) {
        self.name = name
        self.providers = providers
        self.trackedDate = Date()
    }
}
