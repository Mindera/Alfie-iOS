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
