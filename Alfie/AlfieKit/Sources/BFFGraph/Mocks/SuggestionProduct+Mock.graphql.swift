// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class SuggestionProduct: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.SuggestionProduct
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<SuggestionProduct>>

  struct MockFields {
    @Field<String>("brandName") public var brandName
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<[Image]>("images") public var images
    @Field<String>("name") public var name
    @Field<Money>("price") public var price
    @Field<String>("slug") public var slug
  }
}

extension Mock where O == SuggestionProduct {
  convenience init(
    brandName: String? = nil,
    id: BFFGraphAPI.ID? = nil,
    images: [Mock<Image>]? = nil,
    name: String? = nil,
    price: Mock<Money>? = nil,
    slug: String? = nil
  ) {
    self.init()
    _setScalar(brandName, for: \.brandName)
    _setScalar(id, for: \.id)
    _setList(images, for: \.images)
    _setScalar(name, for: \.name)
    _setEntity(price, for: \.price)
    _setScalar(slug, for: \.slug)
  }
}
