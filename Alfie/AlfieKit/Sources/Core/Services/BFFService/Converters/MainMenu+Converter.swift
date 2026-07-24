import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.MainMenuQuery.Data.MainMenu {
    public func convertToNavigationItems() -> [NavigationItem] {
        items.compactMap { $0.convertToNavigationItem() }
    }
}

// Apollo generates a distinct type per nesting level, so each level gets a thin adapter over the
// shared `makeNavigationItem` builder.
extension BFFGraphAPI.MainMenuQuery.Data.MainMenu.Item {
    fileprivate func convertToNavigationItem() -> NavigationItem? {
        makeNavigationItem(
            id: id,
            title: title,
            url: url,
            children: (items ?? []).compactMap { $0?.convertToNavigationItem() }
        )
    }
}

extension BFFGraphAPI.MainMenuQuery.Data.MainMenu.Item.Item {
    fileprivate func convertToNavigationItem() -> NavigationItem? {
        makeNavigationItem(
            id: id,
            title: title,
            url: url,
            children: (items ?? []).compactMap { $0?.convertToNavigationItem() }
        )
    }
}

extension BFFGraphAPI.MainMenuQuery.Data.MainMenu.Item.Item.Item {
    // The query intentionally caps nesting at 3 levels (Shopify's menu depth limit), so the
    // deepest level has no children to convert.
    fileprivate func convertToNavigationItem() -> NavigationItem? {
        makeNavigationItem(id: id, title: title, url: url, children: [])
    }
}

private func makeNavigationItem(
    id: String,
    title: String,
    url rawURL: String?,
    children: [NavigationItem]
) -> NavigationItem? {
    let handleURL = collectionHandleURL(from: rawURL)
    // A leaf that resolves to no collection handle and has no sub-menu isn't actionable — drop it.
    guard !children.isEmpty || handleURL != nil else { return nil }
    return NavigationItem(
        id: id,
        type: .listing,
        title: title,
        url: handleURL,
        media: nil,
        items: children.isEmpty ? nil : children,
        attributes: nil
    )
}

// Reduces a BFF menu path to `/<collection-handle>`: the last path segment, minus any query or
// fragment, lowercased (Shopify handles are lowercase). `didSelectCategory` strips the leading `/`
// and passes the remainder to `productList` as the collectionHandle, so a multi-segment path like
// `/shop/new/dresses` must collapse to `/dresses`.
private func collectionHandleURL(from url: String?) -> String? {
    guard let trimmed = url?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
    let path = trimmed.components(separatedBy: CharacterSet(charactersIn: "?#"))[0]
    guard let handle = path.split(separator: "/").last.map(String.init), !handle.isEmpty else { return nil }
    return "/\(handle.lowercased())"
}
