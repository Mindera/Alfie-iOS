// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Product: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Product
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Product>>

  public struct MockFields {
    @Field<[KeyValuePair]>("attributes") public var attributes
    @Field<Brand>("brand") public var brand
    @Field<[Colour]>("colours") public var colours
    @Field<Variant>("defaultVariant") public var defaultVariant
    @Field<BFFGraphApi.ID>("id") public var id
    @available(*, deprecated, message: "Unavailable from iSAMS, do not use")
    @Field<[String]>("labels") public var labels
    @Field<String>("longDescription") public var longDescription
    @Field<String>("name") public var name
    @Field<PriceRange>("priceRange") public var priceRange
    @Field<String>("shortDescription") public var shortDescription
    @Field<String>("slug") public var slug
    @Field<String>("styleNumber") public var styleNumber
    @Field<[Variant]>("variants") public var variants
  }
}

public extension Mock where O == Product {
  convenience init(
    attributes: [Mock<KeyValuePair>]? = nil,
    brand: Mock<Brand>? = nil,
    colours: [Mock<Colour>]? = nil,
    defaultVariant: Mock<Variant>? = nil,
    id: BFFGraphApi.ID? = nil,
    labels: [String]? = nil,
    longDescription: String? = nil,
    name: String? = nil,
    priceRange: Mock<PriceRange>? = nil,
    shortDescription: String? = nil,
    slug: String? = nil,
    styleNumber: String? = nil,
    variants: [Mock<Variant>]? = nil
  ) {
    self.init()
    _setList(attributes, for: \.attributes)
    _setEntity(brand, for: \.brand)
    _setList(colours, for: \.colours)
    _setEntity(defaultVariant, for: \.defaultVariant)
    _setScalar(id, for: \.id)
    _setScalarList(labels, for: \.labels)
    _setScalar(longDescription, for: \.longDescription)
    _setScalar(name, for: \.name)
    _setEntity(priceRange, for: \.priceRange)
    _setScalar(shortDescription, for: \.shortDescription)
    _setScalar(slug, for: \.slug)
    _setScalar(styleNumber, for: \.styleNumber)
    _setList(variants, for: \.variants)
  }
}
