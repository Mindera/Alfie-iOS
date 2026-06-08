// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Query: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Query
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Query>>

  struct MockFields {
    @Field<OmniProduct>("productDetails") public var productDetails
    @Field<ProductListResponse>("productList") public var productList
  }
}

extension Mock where O == Query {
  convenience init(
    productDetails: Mock<OmniProduct>? = nil,
    productList: Mock<ProductListResponse>? = nil
  ) {
    self.init()
    _setEntity(productDetails, for: \.productDetails)
    _setEntity(productList, for: \.productList)
  }
}
