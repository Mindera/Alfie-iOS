import SwiftUI
import XCTest
@testable import SharedUI

final class BadgeHelperTests: XCTestCase {
    private var sut: BadgeHelper!

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Hide badge

    func test_badge_helper_hides_badge_on_zero_when_configured() {
        sut = BadgeHelper(badgeValue: .constant(0),
                          hideOnZero: true)
        XCTAssertTrue(sut.hideBadge)
    }

    func test_badge_helper_does_not_hide_badge_on_zero_when_configured() {
        sut = BadgeHelper(badgeValue: .constant(0),
                          hideOnZero: false)
        XCTAssertFalse(sut.hideBadge)
    }

    // MARK: - Indicator

    func test_badge_helper_is_indicator_when_value_is_zero_and_does_not_hide() {
        sut = BadgeHelper(badgeValue: .constant(0),
                          hideOnZero: false)
        XCTAssertTrue(sut.isIndicator)
    }

    func test_badge_helper_is_never_indicator_when_hides_badge_on_zero() {
        sut = BadgeHelper(badgeValue: .constant(0),
                          hideOnZero: true)
        XCTAssertFalse(sut.isIndicator)
    }

    // MARK: - Badge label

    func test_badge_helper_returns_empty_label_when_nil() {
        sut = BadgeHelper(badgeValue: .constant(nil),
                          hideOnZero: true)
        XCTAssertTrue(sut.badgeLabel.isEmpty)
    }

    func test_badge_helper_returns_empty_label_when_is_indicator() {
        sut = BadgeHelper(badgeValue: .constant(0),
                          hideOnZero: false)
        XCTAssertTrue(sut.badgeLabel.isEmpty)
    }

    func test_badge_helper_returns_empty_label_when_hidden() {
        sut = BadgeHelper(badgeValue: .constant(0),
                          hideOnZero: true)
        XCTAssertTrue(sut.badgeLabel.isEmpty)
    }

    func test_badge_helper_returns_expected_label_for_regular_value() {
        sut = BadgeHelper(badgeValue: .constant(147),
                          hideOnZero: true)
        XCTAssertEqual(sut.badgeLabel, "99+")
    }

    func test_badge_helper_returns_expected_label_for_max_value() {
        sut = BadgeHelper(badgeValue: .constant(99),
                          hideOnZero: true)
        XCTAssertEqual(sut.badgeLabel, "99")
    }

    func test_badge_helper_returns_expected_label_for_higher_than_max_value() {
        sut = BadgeHelper(badgeValue: .constant(1000),
                          hideOnZero: true)
        XCTAssertEqual(sut.badgeLabel, "99+")
    }

    func test_badge_helper_returns_expected_label_for_negative_value() {
        sut = BadgeHelper(badgeValue: .constant(-1),
                          hideOnZero: true)
        XCTAssertEqual(sut.badgeLabel, "-1")
    }
}
