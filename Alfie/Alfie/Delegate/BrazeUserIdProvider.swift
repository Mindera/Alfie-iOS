import Foundation
import Models

protocol BrazeUserIdProviderProtocol {
    var userId: String { get }
}

struct BrazeUserIdProvider: BrazeUserIdProviderProtocol {
    private let userDefaults: UserDefaultsProtocol
    private let userIDKey = "USER_ID_BRAZE"

    let userId: String

    init(userDefaults: UserDefaultsProtocol) {
        self.userDefaults = userDefaults
        if let userId: String = userDefaults.value(for: userIDKey) {
            self.userId = userId
        } else {
            let userId = "\(UUID())"
            userDefaults.set(userId, for: userIDKey)
            self.userId = userId
        }
    }
}
