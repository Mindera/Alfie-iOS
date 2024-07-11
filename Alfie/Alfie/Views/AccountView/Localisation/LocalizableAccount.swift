import Foundation

struct LocalizableAccount: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title

    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeyAccount"
    }
}
