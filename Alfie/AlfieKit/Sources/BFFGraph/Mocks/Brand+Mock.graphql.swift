// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Brand: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Brand
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Brand>>

  struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<String>("slug") public var slug
  }
}

extension Mock where O == Brand {
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
