import Foundation

struct LocalizableGeneral: LocalizableProtocol {
    @LocalizableResource<Self>(.addToWishlist) static var addToWishlist
    @LocalizableResource<Self>(.color) static var color
    @LocalizableResource<Self>(.loading) static var loading
    @LocalizableResource<Self>(.oneSize) static var oneSize
    @LocalizableResource<Self>(.size) static var size
    @LocalizableResource<Self>(.home) static var home
    @LocalizableResource<Self>(.shop) static var shop
    @LocalizableResource<Self>(.wishlist) static var wishlist
    @LocalizableResource<Self>(.bag) static var bag

    enum Keys: String, LocalizableKeyProtocol {
        case addToWishlist = "KeyAddToWishlist"
        case color = "KeyColor"
        case loading = "KeyLoading"
        case oneSize = "KeyOneSize"
        case size = "KeySize"
        case home = "TabKeyHome"
        case shop = "TabKeyShop"
        case wishlist = "TabKeyWishlist"
        case bag = "TabKeyBag"
    }
}
