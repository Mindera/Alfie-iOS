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
                return "My Details"
            case .myOrders:
                return "My Orders"
            case .wallet:
                return "Wallet"
            case .myAddressBook:
                return "My Address Book"
            case .wishlist:
                return "Wishlist"
            case .signOut:
                return "Sign Out"
        }
    }

    var icon: Icon {
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
    }
}
