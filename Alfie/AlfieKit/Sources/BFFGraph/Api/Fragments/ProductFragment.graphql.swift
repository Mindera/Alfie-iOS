// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  struct ProductFragment: BFFGraphApi.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProductFragment on Product { __typename id styleNumber name brand { __typename ...BrandFragment } priceRange { __typename ...PriceRangeFragment } shortDescription longDescription slug labels attributes { __typename ...AttributesFragment } defaultVariant { __typename ...VariantFragment } variants { __typename ...VariantFragment } colours { __typename ...ColourFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Product }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphApi.ID.self),
      .field("styleNumber", String.self),
      .field("name", String.self),
      .field("brand", Brand.self),
      .field("priceRange", PriceRange?.self),
      .field("shortDescription", String.self),
      .field("longDescription", String?.self),
      .field("slug", String.self),
      .field("labels", [String]?.self),
      .field("attributes", [Attribute]?.self),
      .field("defaultVariant", DefaultVariant.self),
      .field("variants", [Variant].self),
      .field("colours", [Colour]?.self),
    ] }

    /// Unique ID for the product and its variants.
    public var id: BFFGraphApi.ID { __data["id"] }
    /// App refers to products (including variants) as style numbers, so this is the product's unique identifier.
    public var styleNumber: String { __data["styleNumber"] }
    /// The formal name of the product.
    public var name: String { __data["name"] }
    /// The brand of the product.
    public var brand: Brand { __data["brand"] }
    /// For displaying a high and low price range if it exists.
    public var priceRange: PriceRange? { __data["priceRange"] }
    /// One-line description of the product.
    public var shortDescription: String { __data["shortDescription"] }
    /// Detailed description of the product.
    public var longDescription: String? { __data["longDescription"] }
    /// For building canonical URL to PDP.
    public var slug: String { __data["slug"] }
    /// Specific labels such as 'Bestseller' or 'New in'.
    @available(*, deprecated, message: "Unavailable from iSAMS, do not use")
    public var labels: [String]? { __data["labels"] }
    /// Product attributes common to all variants.
    public var attributes: [Attribute]? { __data["attributes"] }
    /// The 'default' variant.
    public var defaultVariant: DefaultVariant { __data["defaultVariant"] }
    /// All variants of the product, including the default one.
    public var variants: [Variant] { __data["variants"] }
    /// Aggregation of all available colours from all variants.
    public var colours: [Colour]? { __data["colours"] }

    /// Brand
    ///
    /// Parent Type: `Brand`
    public struct Brand: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Brand }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(BrandFragment.self),
      ] }

      /// The ID for the brand
      public var id: BFFGraphApi.ID { __data["id"] }
      /// The display name of the brand
      public var name: String { __data["name"] }
      /// A slugified name for URL usage
      public var slug: String { __data["slug"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var brandFragment: BrandFragment { _toFragment() }
      }
    }

    /// PriceRange
    ///
    /// Parent Type: `PriceRange`
    public struct PriceRange: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.PriceRange }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(PriceRangeFragment.self),
      ] }

      /// The lowest price.
      public var low: Low { __data["low"] }
      /// The highest price if not a 'from' range.
      public var high: High? { __data["high"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var priceRangeFragment: PriceRangeFragment { _toFragment() }
      }

      public typealias Low = PriceRangeFragment.Low

      public typealias High = PriceRangeFragment.High
    }

    /// Attribute
    ///
    /// Parent Type: `KeyValuePair`
    public struct Attribute: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(AttributesFragment.self),
      ] }

      /// The key of the pair.
      public var key: String { __data["key"] }
      /// The value of the pair.
      public var value: String { __data["value"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var attributesFragment: AttributesFragment { _toFragment() }
      }
    }

    /// DefaultVariant
    ///
    /// Parent Type: `Variant`
    public struct DefaultVariant: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Variant }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(VariantFragment.self),
      ] }

      /// A unique identifier for the variant.
      public var sku: BFFGraphApi.ID { __data["sku"] }
      /// Size, if applicable.
      public var size: Size? { __data["size"] }
      /// Colour, if applicable.
      public var colour: Colour? { __data["colour"] }
      /// Attributes that are specific for this variant.
      public var attributes: [Attribute]? { __data["attributes"] }
      /// How many of this variant in stock?
      public var stock: Int { __data["stock"] }
      /// How much does it cost?
      public var price: Price { __data["price"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var variantFragment: VariantFragment { _toFragment() }
      }

      public typealias Size = VariantFragment.Size

      public typealias Colour = VariantFragment.Colour

      public typealias Attribute = VariantFragment.Attribute

      public typealias Price = VariantFragment.Price
    }

    /// Variant
    ///
    /// Parent Type: `Variant`
    public struct Variant: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Variant }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(VariantFragment.self),
      ] }

      /// A unique identifier for the variant.
      public var sku: BFFGraphApi.ID { __data["sku"] }
      /// Size, if applicable.
      public var size: Size? { __data["size"] }
      /// Colour, if applicable.
      public var colour: Colour? { __data["colour"] }
      /// Attributes that are specific for this variant.
      public var attributes: [Attribute]? { __data["attributes"] }
      /// How many of this variant in stock?
      public var stock: Int { __data["stock"] }
      /// How much does it cost?
      public var price: Price { __data["price"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var variantFragment: VariantFragment { _toFragment() }
      }

      public typealias Size = VariantFragment.Size

      public typealias Colour = VariantFragment.Colour

      public typealias Attribute = VariantFragment.Attribute

      public typealias Price = VariantFragment.Price
    }

    /// Colour
    ///
    /// Parent Type: `Colour`
    public struct Colour: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Colour }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ColourFragment.self),
      ] }

      /// Unique ID for the colour.
      public var id: BFFGraphApi.ID { __data["id"] }
      /// The name of the colour.
      public var name: String { __data["name"] }
      /// Image resolver for the colour swatch.
      public var swatch: Swatch? { __data["swatch"] }
      /// The product images for the colour
      public var media: [Medium]? { __data["media"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var colourFragment: ColourFragment { _toFragment() }
      }

      public typealias Swatch = ColourFragment.Swatch

      public typealias Medium = ColourFragment.Medium
    }
  }

}