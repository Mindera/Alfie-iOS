// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class Brand: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Brand
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Brand>>

  public struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<String>("slug") public var slug
  }
}

public extension Mock where O == Brand {
  convenience init(
    id: BFFGraphAPI.ID? = nil,
    name: String? = nil,
    slug: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setScalar(slug, for: \.slug)
  }
}
