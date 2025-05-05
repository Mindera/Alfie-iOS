// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct PriceRangeFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PriceRangeFragment on PriceRange { __typename low { __typename ...MoneyFragment } high { __typename ...MoneyFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.PriceRange }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("low", Low.self),
      .field("high", High?.self),
    ] }

    /// The lowest price.
    public var low: Low { __data["low"] }
    /// The highest price if not a 'from' range.
    public var high: High? { __data["high"] }

    /// Low
    ///
    /// Parent Type: `Money`
    public struct Low: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
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

    /// High
    ///
    /// Parent Type: `Money`
    public struct High: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
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