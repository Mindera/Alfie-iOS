import Foundation

public protocol StorageProtocol {
    func isEmpty() throws -> Bool
    func exists(forKey key: String) -> Bool
    func removeAll() throws
    func remove(forKey key: String) throws
    func fileUrl(forKey key: String) -> URL
    func save<T: Codable>(object: T, forKey key: String) throws
    func load<T: Codable>(forKey key: String, as: T.Type, withExpiry expiry: StorageExpiry) throws -> T
}
