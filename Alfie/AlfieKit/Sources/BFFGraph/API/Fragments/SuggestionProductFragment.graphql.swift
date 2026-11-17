// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct SuggestionProductFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SuggestionProductFragment on SuggestionProduct { __typename id name brandName slug price { __typename ...MoneyFragment } images { __typename ...ImageFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionProduct }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("name", String.self),
      .field("brandName", String?.self),
      .field("slug", String.self),
      .field("price", Price?.self),
      .field("images", [Image].self),
    ] }

    public var id: BFFGraphAPI.ID { __data["id"] }
    public var name: String { __data["name"] }
    public var brandName: String? { __data["brandName"] }
    public var slug: String { __data["slug"] }
    public var price: Price? { __data["price"] }
    public var images: [Image] { __data["images"] }

    /// Price
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

    /// Image
    ///
    /// Parent Type: `Image`
    public struct Image: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ImageFragment.self),
      ] }

      public var url: String { __data["url"] }
      public var altText: String? { __data["altText"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var imageFragment: ImageFragment { _toFragment() }
      }
    }
  }

}