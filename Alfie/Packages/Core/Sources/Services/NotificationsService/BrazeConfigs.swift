import Foundation

// MARK: - BrazeConstants

public enum BrazeConstants {
    static let apiKey = "00000000-0000-0000-0000-000000000000"
    static let endPoint = "sdk.braze.com"

    public static var userID: String {
        guard let userID: String = UserDefaults.standard.value(forKey: Constants.userIDKey) as? String else {
            let userID = "\(UUID())"
            UserDefaults.standard.setValue(userID, forKey: Constants.userIDKey)
            return userID
        }
        return userID
    }

    private enum Constants {
        static let userIDKey = "USER_ID_BRAZE"
    }
}
