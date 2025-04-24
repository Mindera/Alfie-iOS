// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class KeyValuePair: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.KeyValuePair
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<KeyValuePair>>

  public struct MockFields {
    @Field<String>("key") public var key
    @Field<String>("value") public var value
  }
}

public extension Mock where O == KeyValuePair {
  convenience init(
    key: String? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(key, for: \.key)
    _setScalar(value, for: \.value)
  }
}
