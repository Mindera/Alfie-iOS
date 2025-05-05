// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Price: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Price
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Price>>

  struct MockFields {
    @Field<Money>("amount") public var amount
    @Field<Money>("was") public var was
  }
}

extension Mock where O == Price {
  convenience init(
    amount: Mock<Money>? = nil,
    was: Mock<Money>? = nil
  ) {
    self.init()
    _setEntity(amount, for: \.amount)
    _setEntity(was, for: \.was)
  }
}
