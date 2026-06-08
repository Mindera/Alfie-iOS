// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class VariantOption: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.VariantOption
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<VariantOption>>

  struct MockFields {
    @Field<String>("name") public var name
    @Field<String>("value") public var value
  }
}

extension Mock where O == VariantOption {
  convenience init(
    name: String? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(name, for: \.name)
    _setScalar(value, for: \.value)
  }
}
