// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class NavMenu: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.NavMenu
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<NavMenu>>

  public struct MockFields {
    @Field<[KeyValuePair?]>("attributes") public var attributes
    @Field<[NavMenuItem]>("items") public var items
  }
}

public extension Mock where O == NavMenu {
  convenience init(
    attributes: [Mock<KeyValuePair>?]? = nil,
    items: [Mock<NavMenuItem>]? = nil
  ) {
    self.init()
    _setList(attributes, for: \.attributes)
    _setList(items, for: \.items)
  }
}
