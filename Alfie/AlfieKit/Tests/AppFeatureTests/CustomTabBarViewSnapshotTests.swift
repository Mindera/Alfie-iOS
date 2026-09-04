import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import AppFeature

// Proves the badge value reaches the bag tab and is drawn on its icon rather than another tab's.
// `BagBadgeTests` covers which number is computed; only a rendered bar shows that the number the
// shopper sees is that one, in the right place. The label logic itself is covered by
// `BadgeHelperTests`.
final class CustomTabBarViewSnapshotTests: XCTestCase {
    private let isRecording = false

    func test_customTabBar_withoutBadge() {
        assertSnapshot(of: makeSut(bagBadgeValue: nil), as: .defaultImage(), record: isRecording)
    }

    func test_customTabBar_withSingleDigitBadge() {
        assertSnapshot(of: makeSut(bagBadgeValue: BagBadge.value(for: .fixture(lines: [.fixture(quantity: 3)]))),
                       as: .defaultImage(),
                       record: isRecording)
    }

    // The case a model-level test cannot make: two lines of quantity 3 and 4 must draw 7, not 2.
    func test_customTabBar_withSummedMultiLineBadge() {
        let cart = Cart.fixture(lines: [
            .fixture(id: "line-1", quantity: 3),
            .fixture(id: "line-2", quantity: 4),
        ])
        assertSnapshot(of: makeSut(bagBadgeValue: BagBadge.value(for: cart)),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_customTabBar_withOverflowBadge() {
        let cart = Cart.fixture(lines: [.fixture(quantity: 150)])
        assertSnapshot(of: makeSut(bagBadgeValue: BagBadge.value(for: cart)),
                       as: .defaultImage(),
                       record: isRecording)
    }

    private func makeSut(bagBadgeValue: Int?) -> UIView {
        CustomTabBarView(
            tabs: [.home, .shop, .bag, .account],
            currentTab: .constant(.home),
            bagBadgeValue: bagBadgeValue,
            popToRootAction: { _ in }
        )
        .embededInContainer()
    }
}
