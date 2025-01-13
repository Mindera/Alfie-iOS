// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class ProductListing: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.ProductListing
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ProductListing>>

  public struct MockFields {
    @Field<Pagination>("pagination") public var pagination
    @Field<[Product]>("products") public var products
    @Field<String>("title") public var title
  }
}

public extension Mock where O == ProductListing {
  convenience init(
    pagination: Mock<Pagination>? = nil,
    products: [Mock<Product>]? = nil,
    title: String? = nil
  ) {
    self.init()
    _setEntity(pagination, for: \.pagination)
    _setList(products, for: \.products)
    _setScalar(title, for: \.title)
  }
}
