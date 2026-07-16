import AccessibilityIdentifiers
import SwiftUI
import XCTest
@testable import AppFeature

final class SplashViewTests: XCTestCase {
    func test_splashView_rendersWithoutCrashing() {
        let host = UIHostingController(rootView: SplashView())
        host.loadViewIfNeeded()
        host.view.layoutIfNeeded()

        XCTAssertNotNil(host.view)
    }

    func test_splashAccessibilityIdentifier_isStable() {
        XCTAssertEqual(AccessibilityID.Splash.screen, "splash.screen")
    }
}
