// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct SizeFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SizeFragment on Size { __typename id value scale description }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Size }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("value", String.self),
      .field("scale", String?.self),
      .field("description", String?.self),
    ] }

    /// Unique size ID.
    public var id: BFFGraphAPI.ID { __data["id"] }
    /// The size value (e.g. XS).
    public var value: String { __data["value"] }
    /// The scale of the size (e.g. US).
    public var scale: String? { __data["scale"] }
    /// A description of the size (e.g. Extra Small).
    public var description: String? { __data["description"] }
  }

}