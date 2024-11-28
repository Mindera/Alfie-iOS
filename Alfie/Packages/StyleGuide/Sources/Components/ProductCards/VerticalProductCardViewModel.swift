import Foundation
import Models

public struct VerticalProductCardViewModel {
    var configuration: VerticalProductCardConfiguration
    var productId: String
    var image: URL?
    var designer: String
    var name: String
    var priceType: PriceType
    var colorTitle: String = ""
    var color: String = ""
    var sizeTitle: String = ""
    var size: String = ""
    var addToBagTitle: String = ""
    var outOfStockTitle: String = ""
    var isAddToBagDisabled = false

    public init(
        configuration: VerticalProductCardConfiguration,
        productId: String,
        image: URL? = nil,
        designer: String,
        name: String,
        priceType: PriceType,
        colorTitle: String = "",
        color: String = "",
        sizeTitle: String = "",
        size: String = "",
        addToBagTitle: String = "",
        outOfStockTitle: String = "",
        isAddToBagDisabled: Bool = false
    ) {
        self.configuration = configuration
        self.productId = productId
        self.image = image
        self.designer = designer
        self.name = name
        self.priceType = priceType
        self.colorTitle = colorTitle
        self.color = color
        self.sizeTitle = sizeTitle
        self.size = size
        self.addToBagTitle = addToBagTitle
        self.outOfStockTitle = outOfStockTitle
        self.isAddToBagDisabled = isAddToBagDisabled
    }
}

public extension VerticalProductCardViewModel {
    init(
        configuration: VerticalProductCardConfiguration,
        product: Product,
        colorTitle: String = "",
        sizeTitle: String = "",
        oneSizeTitle: String = "",
        addToBagTitle: String = "",
        outOfStockTitle: String = "",
        isAddToBagDisabled: Bool = false
    ) {
        self.configuration = configuration
        self.productId = product.id
        self.image = product.defaultVariant.media.first?.asImage?.url
        self.designer = product.brand.name
        self.name = product.name
        self.colorTitle = colorTitle
        self.color = product.defaultVariant.colour?.name ?? ""
        self.sizeTitle = sizeTitle
        self.size = product.isSingleSizeProduct ? oneSizeTitle : product.sizeText
        self.priceType = product.priceType
        self.addToBagTitle = addToBagTitle
        self.outOfStockTitle = outOfStockTitle
        self.isAddToBagDisabled = isAddToBagDisabled
    }
}
