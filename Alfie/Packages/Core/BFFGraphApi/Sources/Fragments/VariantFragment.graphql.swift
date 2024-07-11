// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct VariantFragment: BFFGraphApi.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment VariantFragment on Variant { __typename sku size { __typename ...SizeTreeFragment } colour { __typename id } attributes { __typename ...AttributesFragment } stock price { __typename ...PriceFragment } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Variant }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("sku", BFFGraphApi.ID.self),
    .field("size", Size?.self),
    .field("colour", Colour?.self),
    .field("attributes", [Attribute]?.self),
    .field("stock", Int.self),
    .field("price", Price.self),
  ] }

  /// DJ's unique identifier for the variant.
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

  /// Size
  ///
  /// Parent Type: `Size`
  public struct Size: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Size }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(SizeTreeFragment.self),
    ] }

    /// Unique size ID.
    public var id: BFFGraphApi.ID { __data["id"] }
    /// The size value (e.g. XS).
    public var value: String { __data["value"] }
    /// The scale of the size (e.g. US).
    public var scale: String? { __data["scale"] }
    /// A description of the size (e.g. Extra Small).
    public var description: String? { __data["description"] }
    /// The size guide that includes this size.
    public var sizeGuide: SizeGuide? { __data["sizeGuide"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var sizeTreeFragment: SizeTreeFragment { _toFragment() }
      public var sizeFragment: SizeFragment { _toFragment() }
    }

    /// Size.SizeGuide
    ///
    /// Parent Type: `SizeGuide`
    public struct SizeGuide: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }

      /// Unique size guide ID.
      public var id: BFFGraphApi.ID { __data["id"] }
      /// The name of the size guide (e.g. Men's shoes size guide).
      public var name: String { __data["name"] }
      /// A description for the size guide.
      public var description: String? { __data["description"] }
      /// The ordered list of sizes that make up this size guide.
      public var sizes: [Size] { __data["sizes"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var sizeGuideFragment: SizeGuideFragment { _toFragment() }
        public var sizeGuideTreeFragment: SizeGuideTreeFragment { _toFragment() }
      }

      /// Size.SizeGuide.Size
      ///
      /// Parent Type: `Size`
      public struct Size: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Size }

        /// Unique size ID.
        public var id: BFFGraphApi.ID { __data["id"] }
        /// The size value (e.g. XS).
        public var value: String { __data["value"] }
        /// The scale of the size (e.g. US).
        public var scale: String? { __data["scale"] }
        /// A description of the size (e.g. Extra Small).
        public var description: String? { __data["description"] }
        /// The size guide that includes this size.
        public var sizeGuide: SizeGuide? { __data["sizeGuide"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var sizeFragment: SizeFragment { _toFragment() }
        }

        /// Size.SizeGuide.Size.SizeGuide
        ///
        /// Parent Type: `SizeGuide`
        public struct SizeGuide: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }

          /// Unique size guide ID.
          public var id: BFFGraphApi.ID { __data["id"] }
          /// The name of the size guide (e.g. Men's shoes size guide).
          public var name: String { __data["name"] }
          /// A description for the size guide.
          public var description: String? { __data["description"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var sizeGuideFragment: SizeGuideFragment { _toFragment() }
          }
        }
      }
    }
  }

  /// Colour
  ///
  /// Parent Type: `Colour`
  public struct Colour: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Colour }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphApi.ID.self),
    ] }

    /// Unique ID for the colour.
    public var id: BFFGraphApi.ID { __data["id"] }
  }

  /// Attribute
  ///
  /// Parent Type: `KeyValuePair`
  public struct Attribute: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }
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
  public struct Price: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Price }
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

    /// Price.Amount
    ///
    /// Parent Type: `Money`
    public struct Amount: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

      /// The 3-letter currency code e.g. AUD.
      public var currencyCode: String { __data["currencyCode"] }
      /// The amount in minor units (e.g. for $1.23 this will be 123).
      public var amount: Int { __data["amount"] }
      /// The amount formatted according to the client locale (e.g. $1.23).
      public var amountFormatted: String { __data["amountFormatted"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var moneyFragment: MoneyFragment { _toFragment() }
      }
    }

    /// Price.Was
    ///
    /// Parent Type: `Money`
    public struct Was: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

      /// The 3-letter currency code e.g. AUD.
      public var currencyCode: String { __data["currencyCode"] }
      /// The amount in minor units (e.g. for $1.23 this will be 123).
      public var amount: Int { __data["amount"] }
      /// The amount formatted according to the client locale (e.g. $1.23).
      public var amountFormatted: String { __data["amountFormatted"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var moneyFragment: MoneyFragment { _toFragment() }
      }
    }
  }
}
