// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct ProductDetailsFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProductDetailsFragment on OmniProduct { __typename id name slug brandName descriptionHtml defaultVariantId inventoryTotal priceRange { __typename minVariantPrice { __typename ...MoneyFragment } maxVariantPrice { __typename ...MoneyFragment } } primaryImage { __typename url altText } variants { __typename id sku price { __typename ...MoneyFragment } compareAtPrice { __typename ...MoneyFragment } inventory { __typename available } optionValues { __typename name value } media { __typename url altText } } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.OmniProduct }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("name", String.self),
      .field("slug", String.self),
      .field("brandName", String?.self),
      .field("descriptionHtml", String?.self),
      .field("defaultVariantId", String?.self),
      .field("inventoryTotal", Int?.self),
      .field("priceRange", PriceRange.self),
      .field("primaryImage", PrimaryImage?.self),
      .field("variants", [Variant?]?.self),
    ] }

    public var id: BFFGraphAPI.ID { __data["id"] }
    public var name: String { __data["name"] }
    public var slug: String { __data["slug"] }
    public var brandName: String? { __data["brandName"] }
    public var descriptionHtml: String? { __data["descriptionHtml"] }
    public var defaultVariantId: String? { __data["defaultVariantId"] }
    public var inventoryTotal: Int? { __data["inventoryTotal"] }
    public var priceRange: PriceRange { __data["priceRange"] }
    public var primaryImage: PrimaryImage? { __data["primaryImage"] }
    public var variants: [Variant?]? { __data["variants"] }

    /// PriceRange
    ///
    /// Parent Type: `MoneyRange`
    public struct PriceRange: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.MoneyRange }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("minVariantPrice", MinVariantPrice.self),
        .field("maxVariantPrice", MaxVariantPrice.self),
      ] }

      public var minVariantPrice: MinVariantPrice { __data["minVariantPrice"] }
      public var maxVariantPrice: MaxVariantPrice { __data["maxVariantPrice"] }

      /// PriceRange.MinVariantPrice
      ///
      /// Parent Type: `Money`
      public struct MinVariantPrice: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoneyFragment.self),
        ] }

        public var amount: Double { __data["amount"] }
        public var currencyCode: String { __data["currencyCode"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var moneyFragment: MoneyFragment { _toFragment() }
        }
      }

      /// PriceRange.MaxVariantPrice
      ///
      /// Parent Type: `Money`
      public struct MaxVariantPrice: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoneyFragment.self),
        ] }

        public var amount: Double { __data["amount"] }
        public var currencyCode: String { __data["currencyCode"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var moneyFragment: MoneyFragment { _toFragment() }
        }
      }
    }

    /// PrimaryImage
    ///
    /// Parent Type: `Image`
    public struct PrimaryImage: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("url", String.self),
        .field("altText", String?.self),
      ] }

      public var url: String { __data["url"] }
      public var altText: String? { __data["altText"] }
    }

    /// Variant
    ///
    /// Parent Type: `ProductVariant`
    public struct Variant: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.ProductVariant }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", BFFGraphAPI.ID.self),
        .field("sku", String.self),
        .field("price", Price.self),
        .field("compareAtPrice", CompareAtPrice?.self),
        .field("inventory", Inventory?.self),
        .field("optionValues", [OptionValue].self),
        .field("media", [Medium?]?.self),
      ] }

      public var id: BFFGraphAPI.ID { __data["id"] }
      public var sku: String { __data["sku"] }
      public var price: Price { __data["price"] }
      public var compareAtPrice: CompareAtPrice? { __data["compareAtPrice"] }
      public var inventory: Inventory? { __data["inventory"] }
      public var optionValues: [OptionValue] { __data["optionValues"] }
      public var media: [Medium?]? { __data["media"] }

      /// Variant.Price
      ///
      /// Parent Type: `Money`
      public struct Price: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoneyFragment.self),
        ] }

        public var amount: Double { __data["amount"] }
        public var currencyCode: String { __data["currencyCode"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var moneyFragment: MoneyFragment { _toFragment() }
        }
      }

      /// Variant.CompareAtPrice
      ///
      /// Parent Type: `Money`
      public struct CompareAtPrice: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoneyFragment.self),
        ] }

        public var amount: Double { __data["amount"] }
        public var currencyCode: String { __data["currencyCode"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var moneyFragment: MoneyFragment { _toFragment() }
        }
      }

      /// Variant.Inventory
      ///
      /// Parent Type: `Inventory`
      public struct Inventory: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Inventory }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("available", Int?.self),
        ] }

        public var available: Int? { __data["available"] }
      }

      /// Variant.OptionValue
      ///
      /// Parent Type: `VariantOption`
      public struct OptionValue: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.VariantOption }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("value", String.self),
        ] }

        public var name: String { __data["name"] }
        public var value: String { __data["value"] }
      }

      /// Variant.Medium
      ///
      /// Parent Type: `Image`
      public struct Medium: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", String.self),
          .field("altText", String?.self),
        ] }

        public var url: String { __data["url"] }
        public var altText: String? { __data["altText"] }
      }
    }
  }

}