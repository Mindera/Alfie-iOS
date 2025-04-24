// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class Size: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Size
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Size>>

  public struct MockFields {
    @Field<String>("description") public var description
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<String>("scale") public var scale
    @Field<SizeGuide>("sizeGuide") public var sizeGuide
    @Field<String>("value") public var value
  }
}

public extension Mock where O == Size {
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
