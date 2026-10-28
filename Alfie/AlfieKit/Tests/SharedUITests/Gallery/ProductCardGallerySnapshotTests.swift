import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import SharedUI

final class ProductCardGallerySnapshotTests: XCTestCase {
    private let isRecording = false

    func test_verticalSmall() {
        assertSnapshot(of: verticalCard(size: .small, width: 180).embededInContainer(height: 480),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_verticalMedium() {
        assertSnapshot(of: verticalCard(size: .medium, width: 180).embededInContainer(height: 560),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_horizontal() {
        let sut = HorizontalProductCard(
            viewModel: .init(
                image: nil,
                designer: "Yves Saint Laurent",
                name: "Rouge Pur Couture",
                colorTitle: "Color:",
                color: "104",
                sizeTitle: "Size:",
                size: "No size",
                priceType: .default(price: "$65.00")
            )
        )
        .padding(16)
        assertSnapshot(of: sut.embededInContainer(height: 240), as: .defaultImage(), record: isRecording)
    }

    private func verticalCard(size: VerticalProductCardConfiguration.Size, width: CGFloat) -> some View {
        VerticalProductCard(
            viewModel: .init(
                configuration: .init(size: size),
                productId: "1",
                designer: "Yves Saint Laurent",
                name: "Rouge Pur Couture",
                priceType: .sale(fullPrice: "$80.00", finalPrice: "$65.00"),
                addToBagTitle: "Add to bag"
            ),
            onUserAction: { _, _ in }
        )
        .frame(width: width)
    }
}
