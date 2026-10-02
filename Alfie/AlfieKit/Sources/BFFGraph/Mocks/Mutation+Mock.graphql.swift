// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Mutation: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Mutation
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Mutation>>

  struct MockFields {
    @Field<Cart>("addToCart") public var addToCart
    @Field<Cart>("createCart") public var createCart
    @Field<Cart>("removeFromCart") public var removeFromCart
    @Field<Cart>("updateCart") public var updateCart
  }
}

extension Mock where O == Mutation {
  convenience init(
    addToCart: Mock<Cart>? = nil,
    createCart: Mock<Cart>? = nil,
    removeFromCart: Mock<Cart>? = nil,
    updateCart: Mock<Cart>? = nil
  ) {
    self.init()
    _setEntity(addToCart, for: \.addToCart)
    _setEntity(createCart, for: \.createCart)
    _setEntity(removeFromCart, for: \.removeFromCart)
    _setEntity(updateCart, for: \.updateCart)
  }
}
