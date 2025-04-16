// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  struct AttributesFragment: BFFGraphApi.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment AttributesFragment on KeyValuePair { __typename key value }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("key", String.self),
      .field("value", String.self),
    ] }

    /// The key of the pair.
    public var key: String { __data["key"] }
    /// The value of the pair.
    public var value: String { __data["value"] }
  }

}