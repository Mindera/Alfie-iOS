import ApolloTestSupport
import BFFGraphAPI
import BFFGraphMocks
import XCTest

final class AttributesConverterTests: XCTestCase {
    func test_convert_standard_collection() {
        let mockCollection: [Mock<KeyValuePair>] = [
            .init(key: "key1", value: "value"),
            .init(key: "key2", value: "value"),
            .init(key: "key3", value: "value"),
        ]
        let fragmentCollection: [BFFGraphAPI.AttributesFragment] = mockCollection.map { BFFGraphAPI.AttributesFragment.from($0) }

        let attributeCollection = fragmentCollection.convertToAttributeCollection()

        XCTAssertEqual(attributeCollection.count, 3)
        XCTAssertEqual(attributeCollection["key1"], "value")
        XCTAssertEqual(attributeCollection["key2"], "value")
        XCTAssertEqual(attributeCollection["key3"], "value")
    }

    func test_convert_collection_with_duplicated_keys() {
        let mockCollection: [Mock<KeyValuePair>] = [
            .init(key: "key", value: "value1"),
            .init(key: "key", value: "value2"),
        ]
        let fragmentCollection: [BFFGraphAPI.AttributesFragment] = mockCollection.map { BFFGraphAPI.AttributesFragment.from($0) }

        let attributeCollection = fragmentCollection.convertToAttributeCollection()

        XCTAssertEqual(attributeCollection.count, 1)
        XCTAssertEqual(attributeCollection["key"], "value2")
    }

    func test_convert_collection_with_non_standardized_keys() {
        let mockCollection: [Mock<KeyValuePair>] = [
            .init(key: " ", value: "value1"),
            .init(key: "", value: "value2"),
            .init(key: "", value: "value3"),
        ]
        let fragmentCollection: [BFFGraphAPI.AttributesFragment] = mockCollection.map { BFFGraphAPI.AttributesFragment.from($0) }

        let attributeCollection = fragmentCollection.convertToAttributeCollection()

        XCTAssertEqual(attributeCollection.count, 2)
        XCTAssertEqual(attributeCollection[" "], "value1")
        XCTAssertEqual(attributeCollection[""], "value3")
    }
}
