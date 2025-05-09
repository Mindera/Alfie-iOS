import Foundation
import Model

public final class ProductListingStyleProvider2: ProductListingStyleProviderProtocol2 {
    private let userDefaults: UserDefaultsProtocol
    private let savedPlpListStyle = "PLP_LIST_STYLE"

    private(set) public var style: ProductListingListStyle2 = .grid

    public init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
        guard
            let styleString: String = userDefaults.value(for: savedPlpListStyle),
            let style = ProductListingListStyle2(rawValue: styleString)
        else {
            return
        }

        self.style = style
    }

    public func set(_ style: ProductListingListStyle2) {
        userDefaults.set(style.rawValue, for: savedPlpListStyle)
        self.style = style
    }
}
