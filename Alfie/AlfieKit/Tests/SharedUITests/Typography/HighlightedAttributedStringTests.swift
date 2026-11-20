import SharedUI
import UIKit
import XCTest

final class HighlightedAttributedStringTests: XCTestCase {
    private let highlightFont = UIFont.systemFont(ofSize: 16, weight: .bold)

    func test_every_occurrence_of_the_term_is_highlighted() {
        let parts = highlightedParts(of: "Lorem ipsum lorem", term: "lor")

        XCTAssertEqual(parts, ["Lor", "lor"])
    }

    func test_term_in_another_case_is_highlighted() {
        let parts = highlightedParts(of: "Linen SHIRT", term: "shirt")

        XCTAssertEqual(parts, ["SHIRT"])
    }

    func test_term_with_an_open_parenthesis_is_matched_literally() {
        let parts = highlightedParts(of: "blue shirt( slim", term: "shirt(")

        XCTAssertEqual(parts, ["shirt("])
    }

    func test_term_with_an_open_bracket_is_matched_literally() {
        let parts = highlightedParts(of: "size [m] shirt", term: "[")

        XCTAssertEqual(parts, ["["])
    }

    func test_dot_term_highlights_only_dots() {
        let parts = highlightedParts(of: "st. ives", term: ".")

        XCTAssertEqual(parts, ["."])
    }

    func test_term_that_does_not_occur_highlights_nothing() {
        let parts = highlightedParts(of: "linen dress", term: "shirt(")

        XCTAssertEqual(parts, [])
    }

    func test_empty_term_highlights_nothing() {
        let parts = highlightedParts(of: "linen dress", term: "")

        XCTAssertEqual(parts, [])
    }

    func test_highlighting_a_term_keeps_the_text_unchanged() {
        let highlighted = NSAttributedString(string: "Linen Shirt")
            .hightlightedAttributedString(with: "shirt", font: highlightFont, color: .black)

        XCTAssertEqual(String(highlighted.characters), "Linen Shirt")
    }

    // MARK: - Helpers

    private func highlightedParts(of text: String, term: String) -> [String] {
        let highlighted = NSAttributedString(string: text)
            .hightlightedAttributedString(with: term, font: highlightFont, color: .black)
        return highlighted.runs
            .filter { $0.uiKit.font == highlightFont }
            .map { String(highlighted[$0.range].characters) }
    }
}
