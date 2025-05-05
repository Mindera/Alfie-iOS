import SharedUI

// MARK: - AccountSection

enum AccountSection: CaseIterable {
    case myAddressBook
    case myDetails
    case myOrders
    case signIn
    case signOut
    case wallet
    case wishlist

    var title: String {
        switch self {
        case .myAddressBook:
            "My Address Book"
        case .myDetails:
            "My Details"
        case .myOrders:
            "My Orders"
        case .signIn:
            "Sign In"
        case .signOut:
            "Sign Out"
        case .wallet:
            "Wallet"
        case .wishlist:
            "Wishlist"
        }
    }

    var icon: Icon {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .myAddressBook:
            Icon.location
        case .myDetails:
            Icon.user
        case .myOrders:
            Icon.store
        case .signIn:
            Icon.logIn
        case .signOut:
            Icon.logOut
        case .wallet:
            Icon.chat2
        case .wishlist:
            Icon.heart
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
