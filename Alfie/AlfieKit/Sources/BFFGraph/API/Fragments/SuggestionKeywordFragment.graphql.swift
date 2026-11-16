// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct SuggestionKeywordFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SuggestionKeywordFragment on SuggestionKeyword { __typename value }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionKeyword }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("value", String.self),
    ] }

    public var value: String { __data["value"] }
  }

}