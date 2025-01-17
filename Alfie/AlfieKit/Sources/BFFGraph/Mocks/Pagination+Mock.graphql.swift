// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Pagination: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Pagination
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Pagination>>

  public struct MockFields {
    @Field<Int>("limit") public var limit
    @Field<Int>("nextPage") public var nextPage
    @Field<Int>("offset") public var offset
    @Field<Int>("page") public var page
    @Field<Int>("pages") public var pages
    @Field<Int>("previousPage") public var previousPage
    @Field<Int>("total") public var total
  }
}

public extension Mock where O == Pagination {
  convenience init(
    limit: Int? = nil,
    nextPage: Int? = nil,
    offset: Int? = nil,
    page: Int? = nil,
    pages: Int? = nil,
    previousPage: Int? = nil,
    total: Int? = nil
  ) {
    self.init()
    _setScalar(limit, for: \.limit)
    _setScalar(nextPage, for: \.nextPage)
    _setScalar(offset, for: \.offset)
    _setScalar(page, for: \.page)
    _setScalar(pages, for: \.pages)
    _setScalar(previousPage, for: \.previousPage)
    _setScalar(total, for: \.total)
  }
}
