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

    /// A carousel first built around one reserved placeholder and then handed the real image set
    /// must still show the FIRST image. `offsetIndex` is `@State` seeded at init, so it survives the
    /// item swap; before the fix it stayed at 1 and the gallery opened on the second image while the
    /// indicator still read "1 of N". `realIndex` does not move when this happens, so the assertion
    /// has to be what is actually on screen.
    func test_replacingTheItemSet_showsTheFirstItemNotTheSecond() {
        let placeholder = { [AnyView(Color.gray.aspectRatio(1, contentMode: .fit))] }
        let images = {
            [UIColor.red, UIColor.green, UIColor.blue].map {
                AnyView(Color($0).aspectRatio(1, contentMode: .fit))
            }
        }

        let host = UIHostingController(rootView: carousel(items: placeholder))
        if #available(iOS 16.4, *) {
            host.safeAreaRegions = []
        }
        let window = UIWindow(frame: .init(x: 0, y: 0, width: width, height: 1000))
        window.rootViewController = host
        window.makeKeyAndVisible()
        settle(host)

        // The reserved slot gives way to the real set, exactly as it does when a fetch returns.
        host.rootView = carousel(items: images)
        settle(host)

        let onScreen = centrePixel(of: host, height: width)
        XCTAssertEqual(onScreen.red, 1, accuracy: 0.1, "expected the first image (red) to be centred")
        XCTAssertEqual(onScreen.green, 0, accuracy: 0.1, "green means the carousel opened on image 2")
    }

    private func carousel(items: @escaping () -> [AnyView]) -> some View {
        SnapCarousel(
            itemAspectRatio: nil,
            itemIndex: .constant(0),
            showsAdjacentItemPeek: false,
            items: items
        )
        .frame(width: width)
    }

    private func settle(_ host: UIViewController) {
        for _ in 0 ..< 3 {
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            RunLoop.current.run(until: Date())
        }
    }

    /// Rasterises the carousel and reads the middle pixel — the only way to tell which item the
    /// carousel actually scrolled to, since that lives in the offset rather than in any binding.
    private func centrePixel(of host: UIViewController, height: CGFloat) -> (red: CGFloat, green: CGFloat) {
        host.view.frame = .init(x: 0, y: 0, width: width, height: height)
        host.view.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(bounds: host.view.bounds)
        let image = renderer.image { context in host.view.layer.render(in: context.cgContext) }
        guard let cgImage = image.cgImage else { return (0, 0) }

        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.draw(
            cgImage,
            in: .init(
                x: -CGFloat(cgImage.width) / 2,
                y: -CGFloat(cgImage.height) / 2,
                width: CGFloat(cgImage.width),
                height: CGFloat(cgImage.height)
            )
        )
        return (CGFloat(pixel[0]) / 255, CGFloat(pixel[1]) / 255)
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
