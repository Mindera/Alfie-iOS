// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class PriceRange: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.PriceRange
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<PriceRange>>

  struct MockFields {
    @Field<Money>("high") public var high
    @Field<Money>("low") public var low
  }
}

extension Mock where O == PriceRange {
  convenience init(
    high: Mock<Money>? = nil,
    low: Mock<Money>? = nil
  ) {
    self.init()
    _setEntity(high, for: \.high)
    _setEntity(low, for: \.low)
  }
}
