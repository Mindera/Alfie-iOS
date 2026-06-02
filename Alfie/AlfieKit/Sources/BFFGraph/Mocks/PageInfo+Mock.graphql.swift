// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class PageInfo: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.PageInfo
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<PageInfo>>

  struct MockFields {
    @Field<String>("endCursor") public var endCursor
    @Field<Bool>("hasNextPage") public var hasNextPage
  }
}

extension Mock where O == PageInfo {
  convenience init(
    endCursor: String? = nil,
    hasNextPage: Bool? = nil
  ) {
    self.init()
    _setScalar(endCursor, for: \.endCursor)
    _setScalar(hasNextPage, for: \.hasNextPage)
  }
}
