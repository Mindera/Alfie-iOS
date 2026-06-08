// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Inventory: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Inventory
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Inventory>>

  struct MockFields {
    @Field<Int>("available") public var available
  }
}

extension Mock where O == Inventory {
  convenience init(
    available: Int? = nil
  ) {
    self.init()
    _setScalar(available, for: \.available)
  }
}
