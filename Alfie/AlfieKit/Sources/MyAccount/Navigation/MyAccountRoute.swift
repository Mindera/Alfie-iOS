import Foundation

public enum MyAccountRoute: Hashable {
    case myAccount
    case myAccountIntent(MyAccountIntent)
}
