import Foundation

public struct HorizontalProductCardViewModel {
    public var image: URL?
    public var designer: String = ""
    public var name: String = ""
    public var colorTitle: String = ""
    public var color: String = ""
    public var sizeTitle: String = ""
    public var size: String = ""
    public var priceType: PriceType

    public init(
        image: URL?,
        designer: String = "",
        name: String = "",
        colorTitle: String = "",
        color: String = "",
        sizeTitle: String = "",
        size: String = "",
        priceType: PriceType
    ) {
        self.image = image
        self.designer = designer
        self.name = name
        self.colorTitle = colorTitle
        self.color = color
        self.sizeTitle = sizeTitle
        self.size = size
        self.priceType = priceType
    }
}

public extension HorizontalProductCardViewModel {
    init(product: Product, colorTitle: String = "", sizeTitle: String = "", oneSizeTitle: String = "") {
        self.image = product.defaultVariant.media.first?.asImage?.url
        self.designer = product.brand.name
        self.name = product.name
        self.color = product.defaultVariant.colour?.name ?? ""
        self.size = product.isSingleSizeProduct ? oneSizeTitle : product.sizeText
        self.priceType = product.priceType
        self.colorTitle = colorTitle
        self.sizeTitle = sizeTitle
    }
}
