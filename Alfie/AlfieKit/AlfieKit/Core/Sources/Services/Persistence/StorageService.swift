import EasyStash
import Models

public final class StorageService: StorageServiceProtocol {
    private let storage: StorageProtocol

    public var isEmpty: Bool? {
        do {
            return try storage.isEmpty()
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }

    public init?(customStorage: StorageProtocol? = nil) {
        guard let storage = customStorage ?? (try? Storage(options: .init())) else {
            return nil
        }

        self.storage = storage
    }

    public func hasData(for key: String) -> Bool {
        storage.exists(forKey: key)
    }

    public func save<T: Codable>(object: T, for key: String) throws {
        try storage.save(object: object, forKey: key)
    }

    public func load<T: Codable>(for key: String, as _: T.Type, expiry: StorageExpiry) throws -> T {
        try storage.load(forKey: key, as: T.self, withExpiry: expiry)
    }
}
