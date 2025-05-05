// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Size: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Size
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Size>>

  struct MockFields {
    @Field<String>("description") public var description
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<String>("scale") public var scale
    @Field<SizeGuide>("sizeGuide") public var sizeGuide
    @Field<String>("value") public var value
  }
}

extension Mock where O == Size {
  convenience init(
    description: String? = nil,
    id: BFFGraphAPI.ID? = nil,
    scale: String? = nil,
    sizeGuide: Mock<SizeGuide>? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(description, for: \.description)
    _setScalar(id, for: \.id)
    _setScalar(scale, for: \.scale)
    _setEntity(sizeGuide, for: \.sizeGuide)
    _setScalar(value, for: \.value)
  }
}
