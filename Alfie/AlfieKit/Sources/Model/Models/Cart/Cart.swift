import Foundation

public struct Cart: Hashable {
    public let id: String
    public let lines: [CartLine]
    public let subtotal: Money
    public let grandTotal: Money

    /// Total quantity across all lines — the tab badge value, not `lines.count`.
    public var totalQuantity: Int {
        lines.reduce(0) { $0 + $1.quantity }
    }

    public init(id: String, lines: [CartLine], subtotal: Money, grandTotal: Money) {
        self.id = id
        self.lines = lines
        self.subtotal = subtotal
        self.grandTotal = grandTotal
    }
}

public struct CartLine: Hashable, Identifiable {
    /// The server-assigned line id. This is what `removeFromCart(lineId:)` takes.
    public let id: String
    public let productId: String
    public let variantId: String
    public let sku: String?
    public let name: String?
    public let imageURL: URL?
    public let quantity: Int
    public let unitPrice: Money
    public let lineTotal: Money

    public init(
        id: String,
        productId: String,
        variantId: String,
        sku: String?,
        name: String?,
        imageURL: URL?,
        quantity: Int,
        unitPrice: Money,
        lineTotal: Money
    ) {
        self.id = id
        self.productId = productId
        self.variantId = variantId
        self.sku = sku
        self.name = name
        self.imageURL = imageURL
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.lineTotal = lineTotal
    }
}
