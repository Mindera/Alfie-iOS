import StyleGuide

// MARK: - AccountSection

enum AccountSection: CaseIterable {
    case myDetails
    case myOrders
    case wallet
    case myAddressBook
    case wishlist
    case signOut

    var title: String {
        switch self {
        case .myDetails:
            "My Details"
        case .myOrders:
            "My Orders"
        case .wallet:
            "Wallet"
        case .myAddressBook:
            "My Address Book"
        case .wishlist:
            "Wishlist"
        case .signOut:
            "Sign Out"
        }
    }

    var icon: Icon {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .myDetails:
            Icon.user
        case .myOrders:
            Icon.store
        case .wallet:
            Icon.chat2
        case .myAddressBook:
            Icon.location
        case .wishlist:
            Icon.heart
        case .signOut:
            Icon.logOut
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
