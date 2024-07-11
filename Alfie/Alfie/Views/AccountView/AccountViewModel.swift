import Foundation
import StyleGuide

// MARK: - AccountViewModelProtocol

protocol AccountViewModelProtocol: ObservableObject {
    var sectionList: [AccountSection] { get }
}

// MARK: - AccountViewModel

final class AccountViewModel: AccountViewModelProtocol {
    var sectionList: [AccountSection]

    init() {
        sectionList = AccountSection.allCases
    }
}
