import Foundation

extension URL {
    public var cleanPathComponents: [String] {
        self.pathComponents
            .drop(while: { $0 == "/" })
            .map { $0.lowercased() }
    }

    /// Returns the URLs path removing the initial / (if any)
    public var cleanPath: String {
        self.cleanPathComponents.joined(separator: "/")
    }

    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else {
            return nil
        }

        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }

    public static func fromString(_ string: String) -> URL {
        URL(string: string) ?? URL(fileURLWithPath: "")
    }
}
