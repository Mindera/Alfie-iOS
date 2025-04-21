// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class SizeGuide: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.SizeGuide
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<SizeGuide>>

  struct MockFields {
    @Field<String>("description") public var description
    @Field<BFFGraphApi.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<[Size]>("sizes") public var sizes
  }
}

extension Mock where O == SizeGuide {
  convenience init(
    description: String? = nil,
    id: BFFGraphApi.ID? = nil,
    name: String? = nil,
    sizes: [Mock<Size>]? = nil
  ) {
    self.init()
    _setScalar(description, for: \.description)
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
    _setList(sizes, for: \.sizes)
  }
}
