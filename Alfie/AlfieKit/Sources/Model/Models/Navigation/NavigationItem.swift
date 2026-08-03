import Foundation

public enum NavigationItemType {
    case externalHttp // EXTERNAL_HTTP - An http external link.
    case home // HOME - A home page/screen link.
    case listing // LISTING - A product listing link.
    case page // PAGE - A page link.
    case product // PRODUCT - A product link.
    case search // SEARCH - A search link.
    case account // ACCOUNT - An account page/screen link.
    case wishlist // WISHLIST - A wishlist page/screen link.
}

public struct NavigationItem: Equatable, Hashable {
    public let id: String
    public let type: NavigationItemType
    public let title: String
    public let url: String?
    public let media: Media?
    public let items: [NavigationItem]?
    public let attributes: [String: String]?

    public init(
        id: String = UUID().uuidString,
        type: NavigationItemType,
        title: String,
        url: String?,
        media: Media?,
        items: [NavigationItem]?,
        attributes: AttributeCollection?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.url = url
        self.media = media
        self.items = items
        self.attributes = attributes
    }

    /// Whether this item drills into a sub-category list. Single source of truth for the categories
    /// row chevron and the tap-handling branch, so the two can't disagree.
    public var hasSubCategories: Bool {
        items?.isEmpty == false
    }

    public static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
