import Foundation

struct LocalizableBag: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title
    @LocalizableResource<Self>(.checkout) static var checkout

    static func bagProductDescription(numberOfProducts: Int, locale: Locale = .current) -> LocalizedStringResource {
        .init("KeyProductsInBag", defaultValue: "\(numberOfProducts)", table: tableName, locale: locale)
    }

    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeyBag"
        case checkout = "KeyCheckout"
    }
}
