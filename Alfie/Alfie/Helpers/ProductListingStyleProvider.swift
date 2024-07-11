import Foundation
import Models

final class ProductListingStyleProvider: ProductListingStyleProviderProtocol {
    private let userDefaults: UserDefaultsProtocol
    private let savedPlpListStyle = "PLP_LIST_STYLE"

    private(set) var style: ProductListingListStyle = .grid

    init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
        guard let styleString: String = userDefaults.value(for: savedPlpListStyle),
              let style = ProductListingListStyle(rawValue: styleString) else {
            return
        }

        self.style = style
    }

    func set(_ style: ProductListingListStyle) {
        userDefaults.set(style.rawValue, for: savedPlpListStyle)
        self.style = style
    }
}
