import EasyStash
import Models

extension Storage: StorageProtocol {
    public func load<T: Codable>(forKey key: String, as: T.Type, withExpiry expiry: StorageExpiry) throws -> T {
        try load(forKey: key, as: T.self, withExpiry: easyStashExpiry(from: expiry))
    }

    private func easyStashExpiry(from storageExpiry: StorageExpiry) -> Storage.Expiry {
        switch storageExpiry {
            case .never: return .never
            case .timeInterval(let value): return .maxAge(maxAge: value)
        }
    }
}
