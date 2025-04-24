// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct PaginationFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PaginationFragment on Pagination { __typename offset limit total pages page nextPage previousPage }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Pagination }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("offset", Int.self),
      .field("limit", Int.self),
      .field("total", Int.self),
      .field("pages", Int.self),
      .field("page", Int.self),
      .field("nextPage", Int?.self),
      .field("previousPage", Int?.self),
    ] }

    /// Start point
    public var offset: Int { __data["offset"] }
    /// Records to return
    public var limit: Int { __data["limit"] }
    /// The total number of results
    public var total: Int { __data["total"] }
    /// Based on offset, how many pages are there?
    public var pages: Int { __data["pages"] }
    /// Which page are we on?
    public var page: Int { __data["page"] }
    /// Do we have a next page? (If null, no, else new offset)
    public var nextPage: Int? { __data["nextPage"] }
    /// Do we have a previous page? (If null, no, else new offset)
    public var previousPage: Int? { __data["previousPage"] }
  }

}