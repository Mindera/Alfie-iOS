// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Query: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Query
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Query>>

  struct MockFields {
    @Field<Menu>("mainMenu") public var mainMenu
    @Field<OmniProduct>("productDetails") public var productDetails
    @Field<ProductListResponse>("productList") public var productList
    @Field<ProductListResponse>("searchProducts") public var searchProducts
  }
}

extension Mock where O == Query {
  convenience init(
    mainMenu: Mock<Menu>? = nil,
    productDetails: Mock<OmniProduct>? = nil,
    productList: Mock<ProductListResponse>? = nil,
    searchProducts: Mock<ProductListResponse>? = nil
  ) {
    self.init()
    _setEntity(mainMenu, for: \.mainMenu)
    _setEntity(productDetails, for: \.productDetails)
    _setEntity(productList, for: \.productList)
    _setEntity(searchProducts, for: \.searchProducts)
  }
}
