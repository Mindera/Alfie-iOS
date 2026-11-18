import SharedUI
import UIKit
import XCTest

final class HighlightedAttributedStringTests: XCTestCase {
    private let highlightFont = UIFont.systemFont(ofSize: 16, weight: .bold)

    func test_every_occurrence_of_the_term_is_highlighted() {
        XCTAssertEqual(highlightedParts(of: "Lorem ipsum lorem", term: "lor"), ["Lor", "lor"])
    }

    func test_match_ignores_case() {
        XCTAssertEqual(highlightedParts(of: "Linen SHIRT", term: "shirt"), ["SHIRT"])
    }

    func test_term_with_an_open_parenthesis_is_matched_literally() {
        XCTAssertEqual(highlightedParts(of: "blue shirt( slim", term: "shirt("), ["shirt("])
    }

    func test_term_with_an_open_bracket_is_matched_literally() {
        XCTAssertEqual(highlightedParts(of: "size [m] shirt", term: "["), ["["])
    }

    func test_dot_highlights_only_dots() {
        XCTAssertEqual(highlightedParts(of: "st. ives", term: "."), ["."])
    }

    func test_term_that_does_not_occur_highlights_nothing() {
        XCTAssertEqual(highlightedParts(of: "linen dress", term: "shirt("), [])
    }

    func test_empty_term_highlights_nothing() {
        XCTAssertEqual(highlightedParts(of: "linen dress", term: ""), [])
    }

    func test_text_is_unchanged() {
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
