import XCTest
@testable import Model

final class ThemeServiceTests: XCTestCase {
    private static let suiteName = "com.alfie.test.theme.defaults"

    private var sut: ThemeService!
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults = UserDefaults(suiteName: Self.suiteName)
    }

    override func tearDownWithError() throws {
        sut = nil
        userDefaults.removeSuite(named: Self.suiteName)
        userDefaults.removePersistentDomain(forName: Self.suiteName)
        userDefaults = nil
        try super.tearDownWithError()
    }

    func test_selectedThemeID_isNilByDefault() {
        sut = ThemeService(userDefaults: userDefaults)
        XCTAssertNil(sut.selectedThemeID)
    }

    func test_set_persistsAcrossInstances() {
        sut = ThemeService(userDefaults: userDefaults)
        sut.set("selffridge-theme")
        XCTAssertEqual(sut.selectedThemeID, "selffridge-theme")

        // A fresh instance reads the persisted value.
        sut = ThemeService(userDefaults: userDefaults)
        XCTAssertEqual(sut.selectedThemeID, "selffridge-theme")
    }

    func test_set_overwritesPreviousSelection() {
        sut = ThemeService(userDefaults: userDefaults)
        sut.set("selffridge-theme")
        sut.set("alfie-theme")
        XCTAssertEqual(sut.selectedThemeID, "alfie-theme")
    }
}
