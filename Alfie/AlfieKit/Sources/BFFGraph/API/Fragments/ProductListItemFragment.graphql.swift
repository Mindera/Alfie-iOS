// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct ProductListItemFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProductListItemFragment on OmniProduct { __typename id name slug brandName productType descriptionHtml inventoryTotal primaryImage { __typename url altText } priceRange { __typename minVariantPrice { __typename ...MoneyFragment } maxVariantPrice { __typename ...MoneyFragment } } }"#
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
      .field("productType", String?.self),
      .field("descriptionHtml", String?.self),
      .field("inventoryTotal", Int?.self),
      .field("primaryImage", PrimaryImage?.self),
      .field("priceRange", PriceRange.self),
    ] }

    public var id: BFFGraphAPI.ID { __data["id"] }
    public var name: String { __data["name"] }
    public var slug: String { __data["slug"] }
    public var brandName: String? { __data["brandName"] }
    public var productType: String? { __data["productType"] }
    public var descriptionHtml: String? { __data["descriptionHtml"] }
    public var inventoryTotal: Int? { __data["inventoryTotal"] }
    public var primaryImage: PrimaryImage? { __data["primaryImage"] }
    public var priceRange: PriceRange { __data["priceRange"] }

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
  }

}