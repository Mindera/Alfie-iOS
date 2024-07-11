import Foundation

struct LocalizableGeneral: LocalizableProtocol {
    @LocalizableResource<Self>(.loading) static var loading
    @LocalizableResource<Self>(.home) static var home
    @LocalizableResource<Self>(.shop) static var shop
    @LocalizableResource<Self>(.wishlist) static var wishlist
    @LocalizableResource<Self>(.bag) static var bag

    enum Keys: String, LocalizableKeyProtocol {
        case loading = "KeyLoading"
        case home = "TabKeyHome"
        case shop = "TabKeyShop"
        case wishlist = "TabKeyWishlist"
        case bag = "TabKeyBag"
    }
}
