import Core
import Mocks
import SharedUI
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

final class ZoomableCarouselSnapshotTests: XCTestCase {
    private let isRecording = false

    /// Pages are hosted in their own `UIHostingController`; the fixture image only shows if the
    /// carousel forwards the environment into them.
    func test_zoomable_carousel_pages_load_images_through_the_injected_pipeline() {
        let url = URL(string: "https://cdn.alfie.test/zoomable-0.jpg")!
        let sut = ZoomableCarousel(currentIndex: .constant(0), configuration: .init(isPresented: .constant(true))) {
            [
                RemoteImage(
                    url: url,
                    success: { $0.resizable().scaledToFit() },
                    placeholder: { Color.orange },
                    failure: { _ in Color.red }
                ),
            ]
        }
        .remoteImageFixtures([url: solidImage(.systemTeal)])
        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    private func solidImage(_ colour: UIColor) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 3, height: 4)).image { context in
            colour.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 3, height: 4))
        }
    }
}
