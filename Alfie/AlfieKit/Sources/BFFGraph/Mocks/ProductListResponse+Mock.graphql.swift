// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class ProductListResponse: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.ProductListResponse
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<ProductListResponse>>

  struct MockFields {
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<[OmniProduct]>("products") public var products
    @Field<Int>("totalCount") public var totalCount
  }
}

extension Mock where O == ProductListResponse {
  convenience init(
    pageInfo: Mock<PageInfo>? = nil,
    products: [Mock<OmniProduct>]? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setEntity(pageInfo, for: \.pageInfo)
    _setList(products, for: \.products)
    _setScalar(totalCount, for: \.totalCount)
  }
}
