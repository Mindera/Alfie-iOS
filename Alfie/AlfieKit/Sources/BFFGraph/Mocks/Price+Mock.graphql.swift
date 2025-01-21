// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Price: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Price
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Price>>

  public struct MockFields {
    @Field<Money>("amount") public var amount
    @Field<Money>("was") public var was
  }
}

public extension Mock where O == Price {
  convenience init(
    amount: Mock<Money>? = nil,
    was: Mock<Money>? = nil
  ) {
    self.init()
    _setEntity(amount, for: \.amount)
    _setEntity(was, for: \.was)
  }
}
