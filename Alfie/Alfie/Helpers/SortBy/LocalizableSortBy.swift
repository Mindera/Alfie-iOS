import Foundation

struct LocalizableSortBy: LocalizableProtocol {
    @LocalizableResource<Self>(.mostPopular) static var mostPopular
    @LocalizableResource<Self>(.priceHighToLow) static var priceHighToLow
    @LocalizableResource<Self>(.priceLowToHigh) static var priceLowToHigh
    @LocalizableResource<Self>(.newIn) static var newIn
    @LocalizableResource<Self>(.alphaAsc) static var alphaAsc
    @LocalizableResource<Self>(.alphDesc) static var alphDesc

    enum Keys: String, LocalizableKeyProtocol {
        case mostPopular = "MostPopular"
        case priceHighToLow = "PriceHighToLow"
        case priceLowToHigh = "PriceLowToHigh"
        case newIn = "NewIn"
        case alphaAsc = "AlphaAsc"
        case alphDesc = "AlphDesc"
    }
}
