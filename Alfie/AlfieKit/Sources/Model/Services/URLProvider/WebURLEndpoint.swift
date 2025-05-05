import Foundation

public protocol WebURLEndpoint {
    var path: String { get }
    var parameters: [String: String]? { get }
}

public extension WebURLEndpoint {
    var parameters: [String: String]? {
        nil
    }
}

public extension WebURLEndpoint where Self: RawRepresentable, Self.RawValue == String {
    var path: String {
        rawValue
    }
}
