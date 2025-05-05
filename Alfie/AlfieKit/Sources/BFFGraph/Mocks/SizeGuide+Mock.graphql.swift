// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class SizeGuide: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.SizeGuide
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SizeGuide>>

  public struct MockFields {
    @Field<String>("description") public var description
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<[Size]>("sizes") public var sizes
  }
}

public extension Mock where O == SizeGuide {
  convenience init(
    description: String? = nil,
    id: BFFGraphAPI.ID? = nil,
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
