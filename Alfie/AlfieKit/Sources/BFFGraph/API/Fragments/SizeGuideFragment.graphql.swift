// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct SizeGuideFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SizeGuideFragment on SizeGuide { __typename id name description }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SizeGuide }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("name", String.self),
      .field("description", String?.self),
    ] }

    /// Unique size guide ID.
    public var id: BFFGraphAPI.ID { __data["id"] }
    /// The name of the size guide (e.g. Men's shoes size guide).
    public var name: String { __data["name"] }
    /// A description for the size guide.
    public var description: String? { __data["description"] }
  }

}