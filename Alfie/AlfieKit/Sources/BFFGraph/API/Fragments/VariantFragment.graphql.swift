// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct VariantFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment VariantFragment on Variant { __typename sku size { __typename ...SizeTreeFragment } colour { __typename id } attributes { __typename ...AttributesFragment } stock price { __typename ...PriceFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Variant }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("sku", BFFGraphAPI.ID.self),
      .field("size", Size?.self),
      .field("colour", Colour?.self),
      .field("attributes", [Attribute]?.self),
      .field("stock", Int.self),
      .field("price", Price.self),
    ] }

    /// A unique identifier for the variant.
    public var sku: BFFGraphAPI.ID { __data["sku"] }
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

    /// Size
    ///
    /// Parent Type: `Size`
    public struct Size: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Size }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(SizeTreeFragment.self),
      ] }

      /// The size guide that includes this size.
      public var sizeGuide: SizeGuide? { __data["sizeGuide"] }
      /// Unique size ID.
      public var id: BFFGraphAPI.ID { __data["id"] }
      /// The size value (e.g. XS).
      public var value: String { __data["value"] }
      /// The scale of the size (e.g. US).
      public var scale: String? { __data["scale"] }
      /// A description of the size (e.g. Extra Small).
      public var description: String? { __data["description"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var sizeTreeFragment: SizeTreeFragment { _toFragment() }
        public var sizeFragment: SizeFragment { _toFragment() }
      }

      public typealias SizeGuide = SizeTreeFragment.SizeGuide
    }

    /// Colour
    ///
    /// Parent Type: `Colour`
    public struct Colour: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Colour }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", BFFGraphAPI.ID.self),
      ] }

      /// Unique ID for the colour.
      public var id: BFFGraphAPI.ID { __data["id"] }
    }

    /// Attribute
    ///
    /// Parent Type: `KeyValuePair`
    public struct Attribute: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.KeyValuePair }
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

    /// Price
    ///
    /// Parent Type: `Price`
    public struct Price: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Price }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(PriceFragment.self),
      ] }

      /// The current price.
      public var amount: Amount { __data["amount"] }
      /// If discounted, the previous price.
      public var was: Was? { __data["was"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var priceFragment: PriceFragment { _toFragment() }
      }

      public typealias Amount = PriceFragment.Amount

      public typealias Was = PriceFragment.Was
    }
  }

}