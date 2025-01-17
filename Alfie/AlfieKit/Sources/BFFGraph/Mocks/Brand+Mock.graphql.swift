// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Brand: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Brand
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Brand>>

  public struct MockFields {
    @Field<BFFGraphApi.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<String>("slug") public var slug
  }
}

public extension Mock where O == Brand {
  convenience init(
    id: BFFGraphApi.ID? = nil,
    name: String? = nil,
    slug: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setScalar(slug, for: \.slug)
  }
}
