import AccessibilityIdentifiers
import XCTest
@testable import AppFeature

final class SplashViewTests: XCTestCase {
    func test_splashView_isInstantiable() {
        _ = SplashView()
    }

    func test_splashAccessibilityIdentifier_isStable() {
        XCTAssertEqual(AccessibilityID.Splash.screen, "splash.screen")
    }
}
