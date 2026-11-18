import XCTest

extension XCUIElementQuery {
    func matching(identifierPrefix prefix: String, suffix: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "identifier BEGINSWITH %@ AND identifier ENDSWITH %@", prefix, suffix))
    }

    func matching(identifierPrefix prefix: String, excludingSuffix suffix: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "identifier BEGINSWITH %@ AND NOT identifier ENDSWITH %@", prefix, suffix))
    }
}
