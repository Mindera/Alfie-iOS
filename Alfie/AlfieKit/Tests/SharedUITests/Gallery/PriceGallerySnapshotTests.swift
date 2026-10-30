import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class PriceGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_small_price_renders_every_type() {
        assertGallery(of: .small)
    }

    func test_large_price_renders_every_type() {
        assertGallery(of: .large)
    }

    private func assertGallery(of size: PriceSize, testName: String = #function) {
        let sut = VStack(spacing: 16) {
            PriceComponentView(type: .default(price: "$50.00"),
                               configuration: .init(preferredDistribution: .horizontal, size: size))
            PriceComponentView(type: .sale(fullPrice: "$100.00", finalPrice: "$50.00"),
                               configuration: .init(preferredDistribution: .horizontal, size: size))
            PriceComponentView(type: .sale(fullPrice: "$100.00", finalPrice: "$50.00"),
                               configuration: .init(preferredDistribution: .vertical, size: size))
        }
        assertSnapshot(of: sut.embededInContainer(height: 200),
                       as: .defaultImage(),
                       record: isRecording,
                       testName: testName)
    }
}
