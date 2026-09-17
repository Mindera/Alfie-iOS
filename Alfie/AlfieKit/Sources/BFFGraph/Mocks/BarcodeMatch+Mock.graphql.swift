// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class BarcodeMatch: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.BarcodeMatch
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<BarcodeMatch>>

  struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<BFFGraphAPI.ID>("variantId") public var variantId
  }
}

extension Mock where O == BarcodeMatch {
  convenience init(
    id: BFFGraphAPI.ID? = nil,
    variantId: BFFGraphAPI.ID? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(variantId, for: \.variantId)
  }
}
