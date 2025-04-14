import EasyStash
import Model

extension Storage: StorageProtocol {
    public func load<T: Codable>(forKey key: String, as: T.Type, withExpiry expiry: StorageExpiry) throws -> T {
        try load(forKey: key, as: T.self, withExpiry: easyStashExpiry(from: expiry))
    }

    private func easyStashExpiry(from storageExpiry: StorageExpiry) -> Storage.Expiry {
        // swiftlint:disable vertical_whitespace_between_cases
        switch storageExpiry {
        case .never:
            .never
        case .timeInterval(let value):
            .maxAge(maxAge: value)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
