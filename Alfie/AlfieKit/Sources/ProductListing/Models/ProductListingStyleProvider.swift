import Foundation
import Model

public final class ProductListingStyleProvider: ProductListingStyleProviderProtocol {
    private let userDefaults: UserDefaultsProtocol
    private let savedPlpListStyle = "PLP_LIST_STYLE"

    public private(set) var style: ProductListingListStyle = .grid

    public init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
        guard
            let styleString: String = userDefaults.value(for: savedPlpListStyle),
            let style = ProductListingListStyle(rawValue: styleString)
        else {
            return
        }

        self.style = style
    }

    public func set(_ style: ProductListingListStyle) {
        userDefaults.set(style.rawValue, for: savedPlpListStyle)
        self.style = style
    }
}
