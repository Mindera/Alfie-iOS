@testable import SharedUI
import SwiftUI
import XCTest

/// The hug path measures its item and adopts that height. It is easy to write a version that looks
/// correct and silently settles at zero, so these pin the resolved height rather than the code shape.
final class SnapCarouselHeightTests: XCTestCase {
    private let width: CGFloat = 300

    func test_hugMode_adoptsTheHeightOfItsContent() {
        // A 1:1 item in a 300pt-wide carousel is 300pt tall.
        let height = resolvedHeight(itemAspectRatio: nil) {
            [AnyView(Color.red.aspectRatio(1, contentMode: .fit))]
        }
        XCTAssertEqual(height, width, accuracy: 1)
    }

    func test_hugMode_adoptsATallerContentHeight() {
        // 3:4 — the ratio the gallery used to hardcode. 300 / 0.75 = 400.
        let height = resolvedHeight(itemAspectRatio: nil) {
            [AnyView(Color.red.aspectRatio(0.75, contentMode: .fit))]
        }
        XCTAssertEqual(height, width / 0.75, accuracy: 1)
    }

    func test_hugMode_collapsesWhenThereIsNothingToShow() {
        let height = resolvedHeight(itemAspectRatio: nil) { [] }
        XCTAssertEqual(height, 0, accuracy: 1)
    }

    func test_fixedRatio_isUnaffectedByTheHugPath() {
        let height = resolvedHeight(itemAspectRatio: 0.77) {
            [AnyView(Color.red)]
        }
        XCTAssertEqual(height, width / 0.77, accuracy: 1)
    }

    /// Renders the carousel in a window and lets the measure/adopt round trip settle.
    private func resolvedHeight(
        itemAspectRatio: CGFloat?,
        items: @escaping () -> [AnyView]
    ) -> CGFloat {
        let carousel = SnapCarousel(
            itemAspectRatio: itemAspectRatio,
            itemIndex: .constant(0),
            showsAdjacentItemPeek: false,
            items: items
        )
        let host = UIHostingController(rootView: carousel.frame(width: width))
        if #available(iOS 16.4, *) {
            // Otherwise the fitting size includes the window's safe area and swamps the measurement.
            host.safeAreaRegions = []
        }
        let window = UIWindow(frame: .init(x: 0, y: 0, width: width, height: 1000))
        window.rootViewController = host
        window.makeKeyAndVisible()
        // The height arrives through a preference, so one layout pass is not enough.
        for _ in 0 ..< 3 {
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            RunLoop.current.run(until: Date())
        }
        return host.sizeThatFits(in: .init(width: width, height: .greatestFiniteMagnitude)).height
    }
}
