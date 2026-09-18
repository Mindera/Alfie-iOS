import SharedUI

public enum AccountSection: CaseIterable {
    case personalInformation
    case orders
    case wishlist
    case wallet
    case myAddressBook
    case settings
    case signIn
    case signOut

    var title: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .personalInformation:
            L10n.Account.personalInformation
        case .orders:
            L10n.Account.orders
        case .wishlist:
            L10n.Account.wishlist
        case .wallet:
            L10n.Account.wallet
        case .myAddressBook:
            L10n.Account.addressBook
        case .settings:
            L10n.Account.settings
        case .signIn:
            L10n.Account.signIn
        case .signOut:
            L10n.Account.signOut
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    var icon: Icon {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .personalInformation:
            Icon.user
        case .orders:
            Icon.package
        case .wishlist:
            Icon.heart
        case .wallet:
            Icon.creditCard
        case .myAddressBook:
            Icon.location
        case .settings:
            Icon.settings
        case .signIn:
            Icon.logIn
        case .signOut:
            Icon.logOut
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
