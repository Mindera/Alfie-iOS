import XCTest
@testable import Model

final class ThemeServiceTests: XCTestCase {
    private static let suiteName = "com.alfie.test.theme.defaults"

    private var sut: ThemeService!
    private var userDefaults: UserDefaults!
    private var appDelegate: SpyAppDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults = UserDefaults(suiteName: Self.suiteName)
        appDelegate = SpyAppDelegate()
    }

    override func tearDownWithError() throws {
        sut = nil
        appDelegate = nil
        userDefaults.removeSuite(named: Self.suiteName)
        userDefaults.removePersistentDomain(forName: Self.suiteName)
        userDefaults = nil
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
