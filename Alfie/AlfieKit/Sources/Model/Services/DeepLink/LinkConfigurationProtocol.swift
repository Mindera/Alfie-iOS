import Foundation

public protocol LinkConfigurationProtocol {
    var defaultHttpScheme: String { get }
    var hosts: [String] { get }
    var schemes: [String] { get }

    func isURLSupported(_ url: URL) -> Bool
}

public extension LinkConfigurationProtocol {
    var defaultHttpScheme: String {
        "https"
    }

    func isURLSupported(_ url: URL) -> Bool {
        guard
            url.absoluteString != "about:blank", // Prevents a crash on iOS 16.1
            let scheme = url.scheme,
            let host = url.host()
        else {
            return false
        }
        return schemes.contains(scheme) && hosts.contains(host)
    }
}
