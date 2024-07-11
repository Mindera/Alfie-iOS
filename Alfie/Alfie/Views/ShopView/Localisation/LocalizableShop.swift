import Foundation

struct LocalizableShop: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title
    @LocalizableResource<Self>(.categories) static var categories
    @LocalizableResource<Self>(.brands) static var brands
    @LocalizableResource<Self>(.services) static var services

    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeyShop"
        case categories = "KeyCategories"
        case brands = "KeyBrands"
        case services = "KeyServices"
    }
}
