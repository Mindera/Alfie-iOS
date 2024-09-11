import Apollo
import BFFGraphApi
import Foundation
import Models

extension GraphQLEnum where T == NavMenuItemType {
    func convertToNavigationItemType() -> NavigationItemType {
        guard let type = self.value else {
            return .listing // Assumed default
        }

        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .home:
            return .home
        case .listing:
            return .listing
        case .product:
            return .product
        case .search:
            return .search
        case .page:
            return .page
        case .externalHttp:
            return .externalHttp
        case .account:
            return .account
        case .wishlist:
            return .wishlist
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

extension Collection where Element == GetHeaderNavQuery.Data.Navigation.Item {
    func convertToNavigationItems() -> [NavigationItem] {
        compactMap { $0.convertToNavigationItem() }
    }
}

extension GetHeaderNavQuery.Data.Navigation.Item.Item {
    func convertToNavigationItem() -> NavigationItem {
        NavigationItem(
            type: self.type.convertToNavigationItemType(),
            title: self.title,
            url: self.url,
            media: nil,
            items: nil,
            attributes: self.attributes?.compactMap { $0?.fragments.attributesFragment }.convertToAttributeCollection()
        )
    }
}

extension GetHeaderNavQuery.Data.Navigation.Item {
    func convertToNavigationItem() -> NavigationItem {
        NavigationItem(
            type: self.type.convertToNavigationItemType(),
            title: self.title,
            url: self.url,
            media: self.media?.convertToMedia(),
            items: self.items?.compactMap { $0.convertToNavigationItem() },
            attributes: self.attributes?.compactMap { $0?.fragments.attributesFragment }.convertToAttributeCollection()
        )
    }
}

extension GetHeaderNavQuery.Data.Navigation.Item.Media {
    func convertToMedia() -> Media? {
        guard let mediaImage = self.asImage?.fragments.imageFragment.convertToImage() else {
            return nil
        }

        return .image(mediaImage)
    }
}
