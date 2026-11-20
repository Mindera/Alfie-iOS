import XCTest
@testable import Utils

final class SequenceUniquedTests: XCTestCase {
    func test_uniqued_with_repeated_keys_keeps_first_occurrence_in_order() {
        let result = ["b1", "a1", "b2", "c1", "a2"].uniqued { $0.prefix(1) }

        XCTAssertEqual(result, ["b1", "a1", "c1"])
    }

    func test_uniqued_with_distinct_keys_keeps_every_element() {
        let result = [3, 1, 2].uniqued { $0 }

        XCTAssertEqual(result, [3, 1, 2])
    }

    func test_uniqued_with_no_elements_is_empty() {
        let result = [String]().uniqued { $0 }

        XCTAssertEqual(result, [])
    }

    func test_uniqued_with_key_ignoring_case_treats_values_differing_in_case_as_repeated() {
        let result = ["Shirt", "shirt", "SHIRT dress"].uniqued { $0.lowercased() }

        XCTAssertEqual(result, ["Shirt", "SHIRT dress"])
    }
}
