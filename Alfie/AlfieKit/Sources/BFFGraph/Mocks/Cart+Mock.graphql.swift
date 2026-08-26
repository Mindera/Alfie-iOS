// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Cart: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Cart
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Cart>>

  struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<[CartItem]>("lineItems") public var lineItems
    @Field<CartTotals>("totals") public var totals
  }
}

extension Mock where O == Cart {
  convenience init(
    id: BFFGraphAPI.ID? = nil,
    lineItems: [Mock<CartItem>]? = nil,
    totals: Mock<CartTotals>? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setList(lineItems, for: \.lineItems)
    _setEntity(totals, for: \.totals)
  }
}
