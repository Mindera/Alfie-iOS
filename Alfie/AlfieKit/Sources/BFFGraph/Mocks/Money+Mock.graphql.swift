// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Money: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Money
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Money>>

  struct MockFields {
    @Field<Double>("amount") public var amount
    @Field<String>("currencyCode") public var currencyCode
  }
}

extension Mock where O == Money {
  convenience init(
    amount: Double? = nil,
    currencyCode: String? = nil
  ) {
    self.init()
    _setScalar(amount, for: \.amount)
    _setScalar(currencyCode, for: \.currencyCode)
  }
}
