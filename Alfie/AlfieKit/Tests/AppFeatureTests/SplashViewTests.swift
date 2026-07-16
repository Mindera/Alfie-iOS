import SwiftUI
import XCTest
@testable import AppFeature

final class SplashViewTests: XCTestCase {
    // Smoke test only: guards that `body` builds and renders without crashing. Appearance is a
    // snapshot concern, deferred until the repo-wide snapshot suite is re-enabled.
    func test_splashView_rendersWithoutCrashing() {
        let host = UIHostingController(rootView: SplashView())
        host.loadViewIfNeeded()
        host.view.layoutIfNeeded()

        XCTAssertNotNil(host.view)
    }
}
