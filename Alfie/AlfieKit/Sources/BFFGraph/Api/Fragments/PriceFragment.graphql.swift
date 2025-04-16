// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  struct PriceFragment: BFFGraphApi.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PriceFragment on Price { __typename amount { __typename ...MoneyFragment } was { __typename ...MoneyFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Price }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("amount", Amount.self),
      .field("was", Was?.self),
    ] }

    /// The current price.
    public var amount: Amount { __data["amount"] }
    /// If discounted, the previous price.
    public var was: Was? { __data["was"] }

    /// Amount
    ///
    /// Parent Type: `Money`
    public struct Amount: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Money }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }

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

    /// Was
    ///
    /// Parent Type: `Money`
    public struct Was: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Money }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }

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