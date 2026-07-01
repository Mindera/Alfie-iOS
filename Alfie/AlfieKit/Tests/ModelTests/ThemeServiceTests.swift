import XCTest
@testable import Model

final class ThemeServiceTests: XCTestCase {
    private var sut: ThemeService!
    private var userDefaults: UserDefaults!
    private var appDelegate: SpyAppDelegate!
    // Unique per test run so parallel test classes can't cross-contaminate a shared suite.
    private var suiteName: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "com.alfie.test.theme.defaults.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        appDelegate = SpyAppDelegate()
    }

    override func tearDownWithError() throws {
        sut = nil
        appDelegate = nil
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults.removeSuite(named: suiteName)
        userDefaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func test_selectedThemeID_isNilByDefault() {
        sut = ThemeService(appDelegate: appDelegate, userDefaults: userDefaults)
        XCTAssertNil(sut.selectedThemeID)
    }

    func test_updateThemeAndReboot_persistsAndReboots() {
        sut = ThemeService(appDelegate: appDelegate, userDefaults: userDefaults)
        sut.updateThemeAndReboot("selffridge-theme")

        XCTAssertEqual(sut.selectedThemeID, "selffridge-theme")
        XCTAssertEqual(appDelegate.rebootCount, 1)

        // A fresh instance reads the persisted value.
        let reloaded = ThemeService(appDelegate: appDelegate, userDefaults: userDefaults)
        XCTAssertEqual(reloaded.selectedThemeID, "selffridge-theme")
    }

    func test_updateThemeAndReboot_overwritesPreviousSelection() {
        sut = ThemeService(appDelegate: appDelegate, userDefaults: userDefaults)
        sut.updateThemeAndReboot("selffridge-theme")
        sut.updateThemeAndReboot("alfie-theme")

        XCTAssertEqual(sut.selectedThemeID, "alfie-theme")
        XCTAssertEqual(appDelegate.rebootCount, 2)
    }
}

private final class SpyAppDelegate: NSObject, AppDelegateProtocol {
    private(set) var rebootCount = 0
    func rebootApp() { rebootCount += 1 }
}
