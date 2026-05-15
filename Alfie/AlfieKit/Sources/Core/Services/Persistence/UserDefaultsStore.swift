import Foundation
import Model

public final class UserDefaultsStore: WishlistStoreProtocol, BagStoreProtocol {
    private let userDefaults: UserDefaultsProtocol
    private let storageKey: String

    public init(userDefaults: UserDefaultsProtocol, storageKey: String) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func load() -> [SelectedProduct] {
        guard
            let data: Data = userDefaults.value(for: storageKey),
            let dtos = try? JSONDecoder().decode([PersistedProductDTO].self, from: data)
        else {
            return []
        }
        return dtos.map(\.selectedProduct)
    }

    public func save(_ products: [SelectedProduct]) {
        let dtos = products.map(PersistedProductDTO.init(from:))
        guard let data = try? JSONEncoder().encode(dtos) else { return }
        userDefaults.set(data, for: storageKey)
    }
}
