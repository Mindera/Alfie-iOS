import Models

public final class MockStorageService: StorageServiceProtocol {
    public init() { }

    public var onIsEmptyCalled: (() -> Bool)?
    public var isEmpty: Bool? {
        onIsEmptyCalled?()
    }

    public var onHasDataCalled: ((_ key: String) -> Bool)?
    public func hasData(for key: String) -> Bool {
        onHasDataCalled?(key) ?? false
    }

    public var onSaveCalled: ((_ key: String, _ object: Codable) throws -> Void)?
    public func save<T: Codable>(object: T, for key: String) throws {
        try onSaveCalled?(key, object)
    }

    public var onLoadCalled: ((_ key: String, _ type: Codable.Type, _ expiry: StorageExpiry) throws -> Codable)?
    public func load<T: Codable>(for key: String, as type: T.Type, expiry: StorageExpiry) throws -> T {
        guard let onLoadCalled = onLoadCalled else {
            throw StorageServiceMockError.notFound
        }

        let loadedCodableObject = try onLoadCalled(key, type, expiry)

        guard let castedObject = loadedCodableObject as? T else {
            throw StorageServiceMockError.cantCastToSpecifiedStubbedResult
        }

        return castedObject
    }
}

enum StorageServiceMockError: Error {
     case notFound
     case cantCastToSpecifiedStubbedResult
 }

