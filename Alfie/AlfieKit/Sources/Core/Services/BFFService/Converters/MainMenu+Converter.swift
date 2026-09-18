import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.MainMenuQuery.Data.Menu {
    public func convertToNavigationItems() -> [NavigationItem] {
        items.compactMap { $0.convertToNavigationItem() }
    }
}

// Apollo generates a distinct type per nesting level, so each level gets a thin adapter over the
// shared `makeNavigationItem` builder.
extension BFFGraphAPI.MainMenuQuery.Data.Menu.Item {
    fileprivate func convertToNavigationItem() -> NavigationItem? {
        makeNavigationItem(
            id: id,
            title: title,
            url: url,
            children: (items ?? []).compactMap { $0?.convertToNavigationItem() }
        )
    }
}

extension BFFGraphAPI.MainMenuQuery.Data.Menu.Item.Item {
    fileprivate func convertToNavigationItem() -> NavigationItem? {
        makeNavigationItem(
            id: id,
            title: title,
            url: url,
            children: (items ?? []).compactMap { $0?.convertToNavigationItem() }
        )
    }
}

extension BFFGraphAPI.MainMenuQuery.Data.Menu.Item.Item.Item {
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
    let destination = menuDestination(from: rawURL)
    // A leaf with no actionable destination and no sub-menu isn't actionable — drop it.
    guard !children.isEmpty || destination != nil else { return nil }
    return NavigationItem(
        // Type is irrelevant for a parent with no destination of its own (tapping drills in), so a
        // `.listing` default is harmless there.
        id: id,
        type: destination?.type ?? .listing,
        title: title,
        url: destination?.url,
        media: nil,
        items: children.isEmpty ? nil : children,
        attributes: nil
    )
}

// Routes that are never a PLP, so their handle must not be guessed at.
private let nonListingRoutePrefixes: Set<String> = ["pages", "blogs", "products"]

// Maps a menu url to a domain destination. Shopify nests the handle under `collections`, while
// SCAYLE serves a category path whose last segment is the handle:
//   /collections/<handle>[/<tag>]  → `.listing`, url `/<handle>`   (PLP; only the handle is needed)
//   women/women-108                → `.listing`, url `/women-108`
//   /<handle> (bare)               → `.listing`, url `/<handle>`
// Page, blog and product routes are not listings, and an absolute link outside `collections` points
// at off-app content, so both are dropped rather than guessed. Root `/` and path-less absolute urls
// (`https://host`) have no segments and are dropped too.
private func menuDestination(from url: String?) -> (type: NavigationItemType, url: String)? {
    guard
        let trimmed = url?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty,
        let components = URLComponents(string: trimmed)
    else {
        return nil
    }
    let segments = components.path.split(separator: "/").map { $0.lowercased() }
    guard let first = segments.first else { return nil }

    if first == "collections" {
        // Handle is the segment *after* "collections" — a tag-filtered link like
        // `/collections/all/sale` keeps the tag last — and a bare `/collections` has no handle.
        guard segments.count >= 2 else { return nil }
        return (.listing, "/\(segments[1])")
    }

    guard
        !nonListingRoutePrefixes.contains(first),
        components.host == nil,
        let handle = segments.last
    else {
        return nil
    }

    return (.listing, "/\(handle)")
}
