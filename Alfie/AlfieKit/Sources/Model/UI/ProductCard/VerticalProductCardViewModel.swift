import Foundation

public struct VerticalProductCardViewModel {
    public var configuration: VerticalProductCardConfiguration
    public var productId: String
    public var image: URL?
    public var designer: String
    public var name: String
    public var priceType: PriceType
    public var addToBagTitle: String?
    public var outOfStockTitle: String?
    public var isAddToBagDisabled = false

    public init(
        configuration: VerticalProductCardConfiguration,
        productId: String,
        image: URL? = nil,
        designer: String,
        name: String,
        priceType: PriceType,
        addToBagTitle: String? = nil,
        outOfStockTitle: String? = nil,
        isAddToBagDisabled: Bool = false
    ) {
        self.configuration = configuration
        self.productId = productId
        self.image = image
        self.designer = designer
        self.name = name
        self.priceType = priceType
        self.addToBagTitle = addToBagTitle
        self.outOfStockTitle = outOfStockTitle
        self.isAddToBagDisabled = isAddToBagDisabled
    }
}

public extension VerticalProductCardViewModel {
    init(
        configuration: VerticalProductCardConfiguration,
        product: Product,
        addToBagTitle: String? = nil,
        outOfStockTitle: String? = nil,
        isAddToBagDisabled: Bool = false
    ) {
        self.configuration = configuration
        self.productId = product.id
        self.image = product.defaultVariant.media.first?.asImage?.url
        self.designer = product.brand.name
        self.name = product.name
        self.priceType = product.priceType
        self.addToBagTitle = addToBagTitle
        self.outOfStockTitle = outOfStockTitle
        self.isAddToBagDisabled = isAddToBagDisabled
    }

    init(
        configuration: VerticalProductCardConfiguration,
        selectedProduct: SelectedProduct,
        addToBagTitle: String,
        outOfStockTitle: String
    ) {
        self.init(
            configuration: configuration,
            productId: selectedProduct.id,
            image: selectedProduct.media.first?.asImage?.url,
            designer: selectedProduct.brand.name,
            name: selectedProduct.name,
            priceType: selectedProduct.priceType,
            addToBagTitle: addToBagTitle,
            outOfStockTitle: outOfStockTitle,
            isAddToBagDisabled: selectedProduct.stock == .zero
        )
    }
}
