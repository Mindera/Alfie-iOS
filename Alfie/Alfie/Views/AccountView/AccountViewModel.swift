import Foundation
import Models
import StyleGuide

// MARK: - AccountViewModelProtocol

protocol AccountViewModelProtocol: ObservableObject {
    var sectionList: [AccountSection] { get }
}

// MARK: - AccountViewModel

final class AccountViewModel: AccountViewModelProtocol {
    private(set) var sectionList: [AccountSection]

    private let configurationService: ConfigurationServiceProtocol

    init(configurationService: ConfigurationServiceProtocol) {
        self.configurationService = configurationService
        let isWishlistEnabled = configurationService.isFeatureEnabled(.wishlist)

        sectionList = [.myDetails, .myOrders, .wallet, .myAddressBook, .signOut]
        if isWishlistEnabled {
            sectionList.insert(.wishlist, at: 4)
        }
    }
}
