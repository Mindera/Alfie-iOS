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
    @Field<NavMenu>("navigation") public var navigation
    @available(*, deprecated, message: "use productDetails")
    @Field<Product>("product") public var product
    @available(*, deprecated, message: "use productSummaryListing")
    @Field<ProductListing>("productListing") public var productListing
    @Field<Suggestion>("suggestion") public var suggestion
  }
}

public extension Mock where O == Query {
  convenience init(
    brands: [Mock<Brand>]? = nil,
    navigation: Mock<NavMenu>? = nil,
    product: Mock<Product>? = nil,
    productListing: Mock<ProductListing>? = nil,
    suggestion: Mock<Suggestion>? = nil
  ) {
    self.init()
    _setList(brands, for: \.brands)
    _setEntity(navigation, for: \.navigation)
    _setEntity(product, for: \.product)
    _setEntity(productListing, for: \.productListing)
    _setEntity(suggestion, for: \.suggestion)
  }
}
