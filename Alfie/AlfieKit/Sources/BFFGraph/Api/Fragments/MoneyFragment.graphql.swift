// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MoneyFragment: BFFGraphApi.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MoneyFragment on Money { __typename currencyCode amount amountFormatted }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("currencyCode", String.self),
    .field("amount", Int.self),
    .field("amountFormatted", String.self),
  ] }

  /// The 3-letter currency code e.g. AUD.
  public var currencyCode: String { __data["currencyCode"] }
  /// The amount in minor units (e.g. for $1.23 this will be 123).
  public var amount: Int { __data["amount"] }
  /// The amount formatted according to the client locale (e.g. $1.23).
  public var amountFormatted: String { __data["amountFormatted"] }
}
