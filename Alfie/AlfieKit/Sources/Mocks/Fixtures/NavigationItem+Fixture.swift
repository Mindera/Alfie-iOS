import Foundation
import Models

extension NavigationItem {
    public static let fixtures: [NavigationItem] = [
        NavigationItem.fixture(title: "Designer", url: "/designer"),
        NavigationItem.fixture(title: "Women", url: "/women"),
        NavigationItem.fixture(title: "Men", url: "/men"),
        NavigationItem.fixture(title: "Shoes", url: "/shoes"),
        NavigationItem.fixture(title: "Bags & Accessories", url: "/bags-and-accessories"),
        NavigationItem.fixture(title: "Beauty", url: "/beauty"),
        NavigationItem.fixture(title: "Kids", url: "/kids"),
        NavigationItem.fixture(title: "Home & Food", url: "/home-and-food"),
        NavigationItem.fixture(title: "Electrical", url: "/electrical"),
        NavigationItem.fixture(title: "Sale", url: "/sale"),
        NavigationItem.fixture(title: "Brands", url: "/brand"),
        NavigationItem.fixture(title: "Inspiration", url: "/blog"),
    ]

    public static func fixture(id: String = UUID().uuidString,
                               type: NavigationItemType = .listing,
                               title: String = "",
                               url: String? = nil,
                               media: Media? = nil,
                               items: [NavigationItem]? = nil,
                               attributes: [String: String]? = nil) -> NavigationItem {
        .init(id: id,
              type: type,
              title: title,
              url: url,
              media: media,
              items: items,
              attributes: attributes)
    }
}
