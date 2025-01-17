import ApolloTestSupport
import BFFGraphMocks

extension Mock<KeyValuePair> {
    static func mock(key: String = "key", value: String = "value") -> Mock<KeyValuePair> {
        Mock<KeyValuePair>(key: key,
                           value: value)
    }
}
