// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Query: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<[Brand]>("brands") public var brands
    @Field<[NavMenuItem]>("navigation") public var navigation
    @Field<Product>("product") public var product
    @Field<ProductListing>("productListing") public var productListing
    @Field<Suggestion>("suggestion") public var suggestion
  }
}

public extension Mock where O == Query {
  convenience init(
    brands: [Mock<Brand>]? = nil,
    navigation: [Mock<NavMenuItem>]? = nil,
    product: Mock<Product>? = nil,
    productListing: Mock<ProductListing>? = nil,
    suggestion: Mock<Suggestion>? = nil
  ) {
    self.init()
    _setList(brands, for: \.brands)
    _setList(navigation, for: \.navigation)
    _setEntity(product, for: \.product)
    _setEntity(productListing, for: \.productListing)
    _setEntity(suggestion, for: \.suggestion)
  }
}
