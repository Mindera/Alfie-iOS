public protocol EventProtocol {
    var name: String { get }
    var parameters: [String: Any]? { get }
}
