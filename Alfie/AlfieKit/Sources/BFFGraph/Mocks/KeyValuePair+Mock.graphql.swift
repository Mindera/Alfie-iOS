// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class KeyValuePair: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.KeyValuePair
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<KeyValuePair>>

  struct MockFields {
    @Field<String>("key") public var key
    @Field<String>("value") public var value
  }
}

extension Mock where O == KeyValuePair {
  convenience init(
    key: String? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(key, for: \.key)
    _setScalar(value, for: \.value)
  }
}
