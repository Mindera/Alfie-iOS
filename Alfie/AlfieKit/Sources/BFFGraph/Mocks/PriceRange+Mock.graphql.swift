// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class PriceRange: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.PriceRange
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PriceRange>>

  public struct MockFields {
    @Field<Money>("high") public var high
    @Field<Money>("low") public var low
  }
}

public extension Mock where O == PriceRange {
  convenience init(
    high: Mock<Money>? = nil,
    low: Mock<Money>? = nil
  ) {
    self.init()
    _setEntity(high, for: \.high)
    _setEntity(low, for: \.low)
  }
}
