import Foundation

struct LocalizableWishlist: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title

    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeyWishlist"
    }
}
