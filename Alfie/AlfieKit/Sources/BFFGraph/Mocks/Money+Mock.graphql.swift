// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Money: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Money
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Money>>

  public struct MockFields {
    @Field<Int>("amount") public var amount
    @Field<String>("amountFormatted") public var amountFormatted
    @Field<String>("currencyCode") public var currencyCode
  }
}

public extension Mock where O == Money {
  convenience init(
    amount: Int? = nil,
    amountFormatted: String? = nil,
    currencyCode: String? = nil
  ) {
    self.init()
    _setScalar(amount, for: \.amount)
    _setScalar(amountFormatted, for: \.amountFormatted)
    _setScalar(currencyCode, for: \.currencyCode)
  }
}
