// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class CartTotals: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.CartTotals
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<CartTotals>>

  struct MockFields {
    @Field<Money>("grandTotal") public var grandTotal
    @Field<Money>("subtotal") public var subtotal
  }
}

extension Mock where O == CartTotals {
  convenience init(
    grandTotal: Mock<Money>? = nil,
    subtotal: Mock<Money>? = nil
  ) {
    self.init()
    _setEntity(grandTotal, for: \.grandTotal)
    _setEntity(subtotal, for: \.subtotal)
  }
}
