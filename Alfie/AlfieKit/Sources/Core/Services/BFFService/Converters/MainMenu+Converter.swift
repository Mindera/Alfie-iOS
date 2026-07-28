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

// Maps a Shopify menu url to a domain destination based on its route prefix, so non-collection
// links don't masquerade as (broken) product listings:
//   /collections/<handle>  → `.listing`, url `/<handle>`   (PLP)
//   /pages/…, /blogs/…      → `.page`,    full path kept    (webview)
//   /products/<handle>      → `.product`, full path kept    (product)
//   /<handle> (bare)        → `.listing`, url `/<handle>`   (PLP; also SpecialCategories like /brands)
// Anything else — path-less absolute urls (`https://host`), root `/`, or unrecognized multi-segment
// paths — is dropped rather than guessed. `URLComponents` keeps the host out of the path and drops
// any query/fragment.
private func menuDestination(from url: String?) -> (type: NavigationItemType, url: String)? {
    guard
        let trimmed = url?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty,
        let path = URLComponents(string: trimmed)?.path
    else {
        return nil
    }
    let segments = path.split(separator: "/").map { $0.lowercased() }
    guard let first = segments.first else { return nil }

    switch first {
    case "collections":
        guard let handle = segments.last, !handle.isEmpty else { return nil }
        return (.listing, "/\(handle)")
    case "pages", "blogs":
        return (.page, "/\(segments.joined(separator: "/"))")
    case "products":
        return (.product, "/\(segments.joined(separator: "/"))")
    default:
        // A bare single segment is a collection handle (or a SpecialCategory, matched upstream).
        guard segments.count == 1 else { return nil }
        return (.listing, "/\(first)")
    }
}
