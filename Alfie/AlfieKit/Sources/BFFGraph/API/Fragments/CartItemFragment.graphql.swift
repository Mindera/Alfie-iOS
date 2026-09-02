// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct CartItemFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment CartItemFragment on CartItem { __typename id productId variantId sku name quantity image { __typename url altText } price { __typename ...MoneyFragment } lineTotal { __typename ...MoneyFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.CartItem }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("productId", String?.self),
      .field("variantId", String?.self),
      .field("sku", String?.self),
      .field("name", String?.self),
      .field("quantity", Int.self),
      .field("image", Image?.self),
      .field("price", Price.self),
      .field("lineTotal", LineTotal.self),
    ] }

    public var id: BFFGraphAPI.ID { __data["id"] }
    public var productId: String? { __data["productId"] }
    public var variantId: String? { __data["variantId"] }
    public var sku: String? { __data["sku"] }
    public var name: String? { __data["name"] }
    public var quantity: Int { __data["quantity"] }
    public var image: Image? { __data["image"] }
    public var price: Price { __data["price"] }
    public var lineTotal: LineTotal { __data["lineTotal"] }

    /// Image
    ///
    /// Parent Type: `Image`
    public struct Image: BFFGraphAPI.SelectionSet {
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

    /// LineTotal
    ///
    /// Parent Type: `Money`
    public struct LineTotal: BFFGraphAPI.SelectionSet {
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