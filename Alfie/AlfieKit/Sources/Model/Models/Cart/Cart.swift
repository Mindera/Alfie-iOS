import Foundation

public struct Cart: Hashable {
    public let id: String
    public let lines: [CartLine]
    /// `nil` when the server sent a non-finite amount — see `CartLine.lineTotal`. A total is the
    /// number a shopper checks before checking out, so a fabricated £0.00 is the worst place of
    /// all to state a price they are not being charged.
    public let subtotal: Money?
    public let grandTotal: Money?

    /// Total quantity across all lines — the tab badge value, not `lines.count`.
    public var totalQuantity: Int {
        lines.reduce(0) { $0 + $1.quantity }
    }

    public init(id: String, lines: [CartLine], subtotal: Money?, grandTotal: Money?) {
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
    /// Alt text for `imageURL`, for the bag row's VoiceOver label.
    public let imageAltText: String?
    public let quantity: Int
    /// `nil` when the server sent a non-finite amount — see `lineTotal`.
    public let unitPrice: Money?
    /// `nil` when the server sent a non-finite amount. Rendered as an em dash, never as £0.00 —
    /// a fabricated zero would state a price the shopper is not being charged.
    public let lineTotal: Money?

    public init(
        id: String,
        productId: String,
        variantId: String,
        sku: String?,
        name: String?,
        imageURL: URL?,
        imageAltText: String?,
        quantity: Int,
        unitPrice: Money?,
        lineTotal: Money?
    ) {
        self.id = id
        self.productId = productId
        self.variantId = variantId
        self.sku = sku
        self.name = name
        self.imageURL = imageURL
        self.imageAltText = imageAltText
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.lineTotal = lineTotal
    }
}
