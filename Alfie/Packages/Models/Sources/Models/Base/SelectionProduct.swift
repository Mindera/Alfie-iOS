import Foundation

public struct SelectionProduct: Identifiable {
    public let id: String
    public let name: String
    public let brand: Brand
    public let size: Product.ProductSize?
    public let colour: Product.Colour?
    public let stock: Int
    public let price: Price
    public var media: [Media] {
        colour?.media ?? []
    }

    public init(
        id: String,
        name: String,
        brand: Brand,
        size: Product.ProductSize?,
        colour: Product.Colour?,
        stock: Int,
        price: Price
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.size = size
        self.colour = colour
        self.stock = stock
        self.price = price
    }
}
