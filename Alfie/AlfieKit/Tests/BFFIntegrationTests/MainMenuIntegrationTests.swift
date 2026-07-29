import Model
import XCTest

/// Exercises the real `getHeaderNav` → `mainMenu` seam against a running BFF. Assertions are
/// structural (the menu decodes into actionable items with well-formed handle urls) rather than
/// seed-specific values.
final class MainMenuIntegrationTests: IntegrationTestCase {
    func test_getHeaderNav_returnsActionableItemsWithHandleUrls() async throws {
        let items = try await sut.getHeaderNav(handle: .header)

        try XCTSkipUnless(!items.isEmpty, "Seed BFF returned an empty Shop menu for handle .header")

        // Every actionable leaf (a node with no sub-menu) must carry a `/`-prefixed collection handle;
        // parents that only drill into children may legitimately have no url of their own.
        let leaves = actionableLeaves(in: items)
        XCTAssertFalse(leaves.isEmpty, "Menu returned but no actionable leaf links were present")
        for leaf in leaves {
            let url = try XCTUnwrap(leaf.url, "Actionable leaf \(leaf.title) has no url")
            XCTAssertTrue(url.hasPrefix("/"), "Leaf url should be a `/`-prefixed handle, got \(url)")
            XCTAssertFalse(leaf.title.isEmpty)
        }
    }

    /// Flattens the menu tree to its leaves — nodes with no sub-items, which are the ones that
    /// navigate to a PLP and therefore must resolve to a handle url.
    private func actionableLeaves(in items: [NavigationItem]) -> [NavigationItem] {
        items.flatMap { item -> [NavigationItem] in
            if let children = item.items, !children.isEmpty {
                return actionableLeaves(in: children)
            }
            return [item]
        }
    }
}
