public protocol StorageServiceProtocol {
    var isEmpty: Bool? { get }

    func hasData(for key: String) -> Bool
    func save<T: Codable>(object: T, for key: String) throws
    func load<T: Codable>(for key: String, as type: T.Type, expiry: StorageExpiry) throws -> T
}
