import Foundation
import Model

public final class MockWishlistStore: WishlistStoreProtocol {
    public var loadStub: [SelectedProduct]
    public private(set) var loadCount = 0
    public private(set) var saveInvocations: [[SelectedProduct]] = []
    public var onSaveCalled: (([SelectedProduct]) -> Void)?

    public init(initialContent: [SelectedProduct] = []) {
        self.loadStub = initialContent
    }

    public func load() -> [SelectedProduct] {
        loadCount += 1
        return loadStub
    }

    public func save(_ products: [SelectedProduct]) {
        loadStub = products
        saveInvocations.append(products)
        onSaveCalled?(products)
    }
}
