// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct CartFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment CartFragment on Cart { __typename id lineItems { __typename ...CartItemFragment } totals { __typename subtotal { __typename ...MoneyFragment } grandTotal { __typename ...MoneyFragment } } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Cart }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("lineItems", [LineItem].self),
      .field("totals", Totals.self),
    ] }

    public var id: BFFGraphAPI.ID { __data["id"] }
    public var lineItems: [LineItem] { __data["lineItems"] }
    public var totals: Totals { __data["totals"] }

    /// LineItem
    ///
    /// Parent Type: `CartItem`
    public struct LineItem: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.CartItem }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(CartItemFragment.self),
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

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var cartItemFragment: CartItemFragment { _toFragment() }
      }

      public typealias Image = CartItemFragment.Image

      public typealias Price = CartItemFragment.Price

      public typealias LineTotal = CartItemFragment.LineTotal
    }

    /// Totals
    ///
    /// Parent Type: `CartTotals`
    public struct Totals: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.CartTotals }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("subtotal", Subtotal.self),
        .field("grandTotal", GrandTotal.self),
      ] }

      public var subtotal: Subtotal { __data["subtotal"] }
      public var grandTotal: GrandTotal { __data["grandTotal"] }

      /// Totals.Subtotal
      ///
      /// Parent Type: `Money`
      public struct Subtotal: BFFGraphAPI.SelectionSet {
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

      /// Totals.GrandTotal
      ///
      /// Parent Type: `Money`
      public struct GrandTotal: BFFGraphAPI.SelectionSet {
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