// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Query: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Query
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Query>>

  struct MockFields {
    @Field<ProductListResponse>("productList") public var productList
  }
}

extension Mock where O == Query {
  convenience init(
    productList: Mock<ProductListResponse>? = nil
  ) {
    self.init()
    _setEntity(productList, for: \.productList)
  }
}
