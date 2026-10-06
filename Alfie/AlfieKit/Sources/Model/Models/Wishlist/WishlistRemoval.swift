import Foundation

public struct WishlistRemoval: Equatable, Identifiable {
    public struct Entry: Equatable {
        public let position: Int
        public let selectedProduct: SelectedProduct
    }

    public let id: UUID
    public let productId: String
    public let entries: [Entry]

    public init?(id: UUID = UUID(), productId: String, from content: [SelectedProduct]) {
        let entries = content.enumerated()
            .filter { $0.element.product.id == productId }
            .map { Entry(position: $0.offset, selectedProduct: $0.element) }
        guard !entries.isEmpty else { return nil }

        self.id = id
        self.productId = productId
        self.entries = entries
    }

    public func restored(into content: [SelectedProduct]) -> [SelectedProduct] {
        entries.reduce(into: content) { content, entry in
            guard !content.contains(where: { $0.id == entry.selectedProduct.id }) else { return }

            content.insert(entry.selectedProduct, at: min(entry.position, content.count))
        }
    }
}
